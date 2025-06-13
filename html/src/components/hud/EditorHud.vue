<template>
  <div class="editor">
    <div class="blocks-container">
      <div class="blocks">
        <div class="box editor-holder">
          <span class="editor-text" id="editor-racename"
            >{{ translate("track_name") }} :
            {{ globalStore.creatorData.RaceName }}</span
          >
          <span class="editor-text" id="editor-checkpoints"
            >{{ translate("checkpoints") }} :
            {{
              globalStore.creatorData.Checkpoints
                ? globalStore.creatorData.Checkpoints.length
                : 0
            }}</span
          >
          <span class="editor-text" id="editor-checkpoints"
            >{{ translate("closest_checkpoint") }} :
            {{
              globalStore.creatorData.ClosestCheckpoint
                ? globalStore.creatorData.ClosestCheckpoint
                : "Unknown"
            }}</span
          >
        </div>
        <div class="box editor-holder buttons">
          <span class="editor-text" id="editor-keys-add"
            ><span id="editor-keys-add-button" style="color: rgb(0, 201, 0)">{{
              globalStore.buttons.AddCheckpoint
            }}</span>
            : {{ translate("add_checkpoint") }}
          </span>
          <span
            class="editor-text"
            id="editor-keys-delete"
            v-if="globalStore.creatorData.ClosestCheckpoint"
          >
            <span style="color: rgb(255, 43, 43)">[{{
              globalStore.buttons.DeleteCheckpoint
            }}]</span>
            : {{ translate("delete_checkpoint") }}
            {{ globalStore.creatorData.ClosestCheckpoint }}
          </span>
          <span class="editor-text" id="editor-keys-edit"
            ><span id="editor-keys-edit-button" style="color: rgb(0, 201, 0)">[{{
              globalStore.buttons.MoveCheckpoint
            }}]</span
            >: {{ translate("modify_checkpoint") }}
          </span>
          <span class="editor-text" id="editor-keys-tiredistance">
            <span style="margin-right: 0.5em; color: rgb(255, 43, 43)">[{{
              globalStore.buttons.DecreaseDistance
            }}]</span>
            <span style="color: rgb(0, 201, 0)">
              [{{ globalStore.buttons.IncreaseDistance }}]
            </span>
            {{ translate("tire_distance") }} :
            [{{ globalStore.creatorData.TireDistance }}]
          </span>
          <span class="editor-text" id="editor-keys-cancel"
            ><span
              id="editor-keys-cancel-button"
              style="color: rgb(255, 43, 43)"
              >[{{ globalStore.buttons.Exit }}]</span
            >
            : {{ translate("close_editor") }}
          </span>
          <span class="editor-text" id="editor-keys-save"
            ><span id="editor-keys-save-button" style="color: rgb(0, 201, 0)">[{{
              globalStore.buttons.SaveRace
            }}]</span>
            :{{ translate("save_track") }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";
import { translate } from "@/helpers/translate";

const globalStore = useGlobalStore();
</script>

<style scoped lang="scss">
@use 'vuetify/settings' as *;

.editor {
  position: absolute;
  top: 1vh;
  right: 1vw;
  z-index: 10;
}

.editor-holder {
  display: flex;
  flex-direction: column;
  gap: 0.4em;
  padding: 0.5vh;
}

.boxes {
  display: flex;
  justify-content: flex-end;
}

.blocks-container,
.positions-container {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  gap: 1vh;
  padding: 0.5vh 1vw;
  flex-wrap: wrap;
}

.blocks {
  flex: 1 1 25em;
  display: flex;
  flex-direction: column;
  gap: 0.4em;
  min-width: 250px;
}

.box {
  background: linear-gradient(
    to right,
    rgba(var(--v-theme-primary), 0.2),
    rgba(var(--v-theme-primary), 0.5),
    rgba(var(--v-theme-primary), 0.8)
  );
  backdrop-filter: blur(6px);
  width: 100%;
  font-size: 0.95em;
  display: flex;
  align-items: center;
  gap: 0.6em;
  padding: 0.6rem 1rem;
  border-radius: 12px;
  box-shadow: 0 2px 6px rgba(var(--v-theme-primary), 0.15);
}

.hud-text {
  text-align: right;
  padding: 0.25rem 0.75rem;
  font-weight: 500;
  width: 100%;
  color: var(--font-color, #fff);
  text-shadow: 0 0 4px rgba(0, 0, 0, 0.6);
}

.leftAligned {
  text-align: left;
}

.split {
  display: flex;
  justify-content: space-between;
  width: 100%;
}

.buttons {
  font-size: 0.9em;
  display: flex;
  align-items: flex-end;
  justify-content: flex-end;
  margin-left: auto;
  padding-left: 0.5em;
  gap: 0.4em;
}
</style>

