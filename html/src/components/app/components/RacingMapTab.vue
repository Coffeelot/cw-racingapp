<template>
  <div class="map-page-container">
    <div class="subheader">
      <v-spacer></v-spacer>
      <v-switch
        color="primary"
        v-model="globalStore.$state.showOnlyCurated"
        hide-details
        density="compact"
        class="mr-1"
        @click="resetTrackMarkers"
      >
        <template #label>
          {{ globalStore.$state.showOnlyCurated ? translate("showing_curated") : translate("showing_all") }}
        </template>
      </v-switch>
    </div>
    <v-card border class="fill-height">
      <v-card-text class="fill-height pa-0">
        <div class="map-wrapper">
          <div ref="mapContainer" class="map"></div>
        </div>
      </v-card-text>
    </v-card>
    <SetupRaceDialog
      v-if="selectedTrack"
      :open="!!selectedTrack"
      :track="selectedTrack"
      @goBack="resetTrackSetup()"
    />
  </div>
</template>

<script setup lang="ts">
import "maplibre-gl/dist/maplibre-gl.css";
import { closeApp } from "@/helpers/closeApp";
import { gameToMap } from "@/helpers/gameToMap";
import { ref, computed, onMounted, Ref } from "vue";
import { Track } from "@/store/types";
import { translate } from "@/helpers/translate";
import { useGlobalStore } from "@/store/global";
import { useTheme } from "vuetify/lib/framework.mjs";
import api from "@/api/axios";
import maplibregl, { LngLat, LngLatBounds, Map } from "maplibre-gl";
import SetupRaceDialog from "./SetupRaceDialog.vue";

const theme = useTheme();
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
        "line-color": theme.themes.value.dark.colors.primary,
        "line-width": 3,
      },
    });
  
    // Add popup for track details
    currentPopup.value = new maplibregl.Popup({ closeOnClick: false })
      .setLngLat(gameToMap(track.Checkpoints[0].coords.x, track.Checkpoints[0].coords.y))
      .setHTML(`
        <div class="popup-content">
          <h2>${track.RaceName}</h2>
          <h3>${translate("creator")}: ${track.CreatorName}</h3>
          <div class="popup-actions">
            <button 
              class="popup-button"
              ${track.Waiting || track.Started ? 'disabled' : ''}
              onclick="setWaypoint('${track.TrackId}')"
            >
              ${translate("set_waypoint")}
            </button>
            <button 
              class="popup-button"
              ${track.Waiting || track.Started ? 'disabled' : ''}
              onclick="selectTrack('${track.TrackId}')"
            >
              ${translate("setup_race")}
            </button>
          </div>
        </div>
      `).addTo(map.value);
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
  if (track.Started) return theme.themes.value.dark.colors.error;
  if (track.Waiting) return theme.themes.value.dark.colors.success;
  return theme.themes.value.dark.colors.primary;
};

// Reset track setup
const resetTrackSetup = () => {
  selectedTrack.value = undefined;
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
  
    map.value.on("click", (event) => {
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

const setWaypoint = (trackId: string) => {
  const track = filteredTracks.value.find(t => t.TrackId === trackId);
  api.post('UiSetWaypoint', JSON.stringify(track))
  closeApp()
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
  // Select a track
  window.setWaypoint = (raceId: string) => {
    setWaypoint(raceId);
  };
  window.selectTrack = (raceId: string) => {
    selectTrack(raceId);
  };
  generateMap()
});
</script>

<style lang="scss">
@use 'vuetify/settings' as vuetify-settings;

.popup-button {
  background-color: rgb(var(--v-theme-primary));
  color: white;
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
  background: rgb(var(--v-theme-primary));
  color: white;
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
  background-color: rgb(var(--v-theme-surface));
}

.maplibregl-popup-anchor-bottom .maplibregl-popup-tip {
  border-top-color: rgb(var(--v-theme-surface));
}

.popup-content {
  padding: 16px;
}

.popup-actions {
  display: flex;
  flex-direction: column;
  gap: 1em;
  margin-top: 1em;
}

.maplibregl-popup-close-button {
  width: 2em;
  border-radius: 2em;
  color: white;
  height: 2em;
  margin: 0.5em;
}

.maplibregl-popup-close-button:hover {
  color: rgb(var(--v-theme-primary));
}
.map-page-container {
  max-height: calc(80vh - 120px - 3em) !important;
}
</style>