<template>
  <div class="map-page-container">
    <div class="subheader flex items-center">
      <div class="flex-1"></div>
      <div class="flex items-center gap-2">
        <Label for="track-markers">
          {{ translate('curated_only') }}
        </Label>
        <Switch
        is="track-markers"
          :model-value="globalStore.$state.showOnlyCurated"
          class="mr-1 mb-1"
          @update:model-value="resetTrackMarkers"
        >
        </Switch>
      </div>
    </div>
    <div class="map-wrapper border">
      <div ref="mapContainer" class="map"></div>
    </div>
  </div>
</template>

<script setup lang="ts">
import "maplibre-gl/dist/maplibre-gl.css";
import { gameToMap } from "@/helpers/gameToMap";
import { ref, computed, onMounted, Ref, createApp } from "vue";
import { Track } from "@/store/types";
import { translate } from "@/helpers/translate";
import { useGlobalStore } from "@/store/global";
import api from "@/api/axios";
import maplibregl, { LngLat, LngLatBounds, Map } from "maplibre-gl";
import { Switch } from "@/components/ui/switch";
import Label from "@/components/ui/label/Label.vue";
import MapPopup from "./MapPopup.vue";

const globalStore = useGlobalStore();
const mapContainer = ref(undefined);
const map: Ref<Map | undefined> = ref(undefined);
const checkpointsToShow: Ref<Track | undefined> = ref(undefined);
const selectedTrack: Ref<Track | undefined> = ref(undefined);
const loadingTracks = ref(false)

const currentTrackMarkers: Ref<maplibregl.Marker[]> = ref([]);
const currentTrackPolylineId: Ref<string | undefined> = ref(undefined);
const currentPopup: Ref<maplibregl.Popup | undefined> = ref(undefined);

const currentMarkers: Ref<maplibregl.Marker[]> = ref([])

// Map configuration
const mapUrl = "https://s.rsg.sc/sc/images/games/GTAV/map/game/{z}/{x}/{y}.jpg";
const mapCenter = [-100.43, 0.74];
const mapZoom = 4;

const getThemeColors = (): Record<string, string> => {
  const root = document.documentElement;
  return {
    primary: getComputedStyle(root).getPropertyValue('--primary').trim(),
    background: getComputedStyle(root).getPropertyValue('--background').trim(),
    foreground: getComputedStyle(root).getPropertyValue('--foreground').trim(),
    destructive: getComputedStyle(root).getPropertyValue('--destructive').trim(),
    mapColor: getComputedStyle(root).getPropertyValue('--color-map-accent').trim(),
    // Add more as needed
  };
};

// Add markers for filtered tracks
const addTrackMarkers = () => {
  if (map.value) {
    filteredTracks.value.forEach((track) => {
      if (!map.value) return
      const marker = new maplibregl.Marker({
        element: createMarkerElement(track),
      })
        .setLngLat(gameToMap(track.Checkpoints[0].coords.x, track.Checkpoints[0].coords.y))
        .addTo(map.value);
  
      marker.getElement().addEventListener("click", () => {
        showTrackCheckpoints(track);
      });
      currentMarkers.value.push(marker)
    });
  }
};

const resetTrackMarkers = () => {
  console.log('uh')
  globalStore.$state.showOnlyCurated = !globalStore.$state.showOnlyCurated;
  setTimeout(() => {
    currentMarkers.value.forEach((marker) => 
      marker.remove()
    )
    currentMarkers.value = []
    addTrackMarkers()
  }, 100);
}

const cleanupTrackDisplay = () => {
  // Remove all checkpoint markers
  currentTrackMarkers.value.forEach(marker => marker.remove());
  currentTrackMarkers.value = [];

  // Remove polyline if it exists
  if (currentTrackPolylineId.value && map.value) {
    // Remove the layer first
    if (map.value.getLayer(currentTrackPolylineId.value)) {
      map.value.removeLayer(currentTrackPolylineId.value);
    }
    // Then remove the source
    if (map.value.getSource(currentTrackPolylineId.value)) {
      map.value.removeSource(currentTrackPolylineId.value);
    }
    currentTrackPolylineId.value = undefined;
  }
    // Remove popup if it exists
    if (currentPopup.value) {
    currentPopup.value.remove();
    currentPopup.value = undefined;
  }
};

// Create a custom marker element
const createMarkerElement = (track: Track) => {
  const el = document.createElement("div");
  el.className = "marker";
  el.style.color = getIconColor(track);
  // Create an SVG element
  const svgNS = "http://www.w3.org/2000/svg"; // SVG namespace
  const svg = document.createElementNS(svgNS, "svg");
  svg.setAttribute("viewBox", "0 0 24 24");
  svg.setAttribute("width", "34");
  svg.setAttribute("height", "34");

  // Create the path element for the "Place" icon
  const path = document.createElementNS(svgNS, "path");
  path.setAttribute("d", "M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z");
  path.setAttribute("fill", "currentColor"); // Use currentColor to inherit the color from the parent

  // Append the path to the SVG
  svg.appendChild(path);

  // Append the SVG to the div
  el.appendChild(svg);
  return el;
};

// Show checkpoints for a track
const showTrackCheckpoints = (track: Track) => {
  // Clean up previous track display
  cleanupTrackDisplay();
  
  checkpointsToShow.value = track;

  if (map.value) {
    // Add checkpoint markers
    const mapColor =  getThemeColors().mapColor;
    track.Checkpoints.forEach((checkpoint, index) => {
      if (!map.value) return;
      
      const marker = new maplibregl.Marker({
        element: createCheckpointElement(index + 1, `${track.TrackId}-${index}`),
      })
        .setLngLat(gameToMap(checkpoint.coords.x, checkpoint.coords.y))
        .addTo(map.value);
        
      currentTrackMarkers.value.push(marker);
    });

    // Add polyline for checkpoints
    const coordinates = track.Checkpoints.map((checkpoint) =>
      gameToMap(checkpoint.coords.x, checkpoint.coords.y)
    );

    const polylineId = `polyline-${track.TrackId}`;
    currentTrackPolylineId.value = polylineId;
  
    // Add a GeoJSON source for the polyline
    map.value.addSource(polylineId, {
      type: "geojson",
      data: {
        type: "Feature",
        properties: {},
        geometry: {
          type: "LineString",
          coordinates: coordinates,
        },
      },
    });
  
    // Add a layer for the polyline
    map.value.addLayer({
      id: polylineId,
      type: "line",
      source: polylineId,
      layout: {},
      paint: {
        "line-color": mapColor, // Use primary color from theme',
        "line-width": 3,
      },
    });
    const container = document.createElement('div')
    createApp(MapPopup, { track, closePopup: () => resetTrackSetup() }).mount(container)
    // Add popup for track details
    currentPopup.value = new maplibregl.Popup({ closeOnClick: false })
      .setLngLat(gameToMap(track.Checkpoints[0].coords.x, track.Checkpoints[0].coords.y))
      .setDOMContent(container)
      .addTo(map.value);
  }

};

// Create a custom checkpoint marker element
const createCheckpointElement = (index: number, id: string) => {
  const el = document.createElement("div");
  el.className = "checkpoint-marker";
  el.id = id;
  el.innerText = index.toString();
  el.onclick = () => cleanupTrackDisplay()
  return el;
};

// Get marker color based on track status
const getIconColor = (track: Track) => {
  const themeColors = getThemeColors();

  if (track.Started) return themeColors.destructive;
  return themeColors.mapColor;
};

// Reset track setup
const resetTrackSetup = () => {
  selectedTrack.value = undefined;
  currentPopup.value?.remove();
};

// Filtered tracks
const filteredTracks = computed(() => {
  let tracks = globalStore.$state.tracks;
  if (!tracks || tracks.length === 0) return [];

  if (globalStore.$state.showOnlyCurated) {
    tracks = tracks.filter((track) => track.Curated);
  }
  return tracks.filter((track) => track.Checkpoints?.[0]?.coords?.x && track.Checkpoints?.[0]?.coords?.y);
});

const generateMap = () => {
  if (mapContainer.value) {
    let sw = new LngLat(-168, -57.8 );
    let ne = new LngLat(0, 85.8002);
    let llb = new LngLatBounds(sw, ne);

    map.value = new maplibregl.Map({
      container: mapContainer.value,
      style: {
        version: 8,
        sources: {
          raster: {
            type: "raster",
            tiles: [mapUrl],
            tileSize: 256,
          },
        },
        layers: [
          {
            id: "raster-layer",
            type: "raster",
            source: "raster",
            minzoom: 2,
            maxzoom: 5,
          },
        ],
      },
      center: mapCenter as [number, number],
      zoom: mapZoom,
      minZoom: 3,
      maxZoom: 5,
      bounds: llb
    });
  
    map.value.on("click", (event: any) => {
      // Get features at click point
      if (!map.value) return;
      const features = map.value.queryRenderedFeatures(event.point, {
        layers: ['raster-layer'] // Only check clicks on the base map layer
      });
      if (features.length > 0) {
        cleanupTrackDisplay();
        checkpointsToShow.value = undefined;
        // if (import.meta.env.VITE_USE_MOCK_DATA === 'true') console.log(event.lngLat);
      }
      checkpointsToShow.value = undefined;
    });

    // Add markers for tracks
    map.value.on("load", () => {
      addTrackMarkers();
      if (map.value) map.value.resize(); // Trigger a resize after the map is loaded
    });
  

  }
}

const getTracks = async () => {
  loadingTracks.value = true
  if (import.meta.env.VITE_USE_MOCK_DATA === 'true') {
    console.log("MOCK DATA ACTIVE. SKIPPING FETCH");
    return;
  }
  const res = await api.post("UiGetAvailableTracks");
  if (res) {
    globalStore.$state.tracks = res.data;
  }
  loadingTracks.value = false
  generateMap()
};

const selectTrack = (trackId: string) => {
  const track = filteredTracks.value.find(t => t.TrackId === trackId);
  selectedTrack.value = track;
};


// Add type declaration for window
declare global {
  interface Window {
    selectTrack: (raceId: string) => void;
    setWaypoint: (raceId: string) => void;
  }
}

// Initialize the map
onMounted(() => {
  getTracks();

  window.selectTrack = (raceId: string) => {
    selectTrack(raceId);
  };
  generateMap()
});
</script>

<style >
.popup-button {
  border: none;
  border-radius: 9999px;
  padding: 8px 16px;
  font-size: 0.875rem;
  cursor: pointer;
  transition: opacity 0.2s;
}

.popup-button:hover {
  opacity: 0.8;
}

.popup-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.map-wrapper {
  width: 100%;
  height: calc(80vh - 120px - 7em);
  position: relative;
}

.map {
  width: 100%;
  height: 100%;
}

.marker {
  font-size: 24px;
  cursor: pointer;
}

.checkpoint-marker {
  color: white;
  background: var(--background);
  font-weight: bold;
  border-radius: 50%;
  padding: 4px;
  font-size: 12px;
  text-align: center;
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.maplibregl-popup-content {
  background-color: none;     /* same as shadcn card background */
  background: none;
  width: fit-content;
  /* border-color: var(--border);
  border: 1px solid;
  border-radius: var(--radius-xl);            /* match card border radius
  padding: 1rem; */
}

.maplibregl-popup-anchor-bottom .maplibregl-popup-tip {
}
.maplibregl-popup-close-button {
  width: 2em;
  border-radius: 2em;
  color: white;
  height: 2em;
  margin: 0.5em;
}

.maplibregl-popup-close-button:hover {
  color: rgb(var(--primary));
}
.map-page-container {
  max-height: calc(80vh - 120px - 3em) !important;
}
</style>