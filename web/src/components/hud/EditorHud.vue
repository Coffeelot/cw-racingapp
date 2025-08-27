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

<style scoped >
.editor {
  color: #ffffffc7;
  text-shadow:1px 1px 18px black;
  position: absolute;
  top: 10px;
  right: 10px;
}

.editor-holder {
  display: flex;
  flex-direction: column;
  gap: 0.5em;
}
.boxes {
  display: flex;
  justify-content: end;
}
.blocks-container {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  gap: 20px;
  margin: 10px;
}

.positions-container {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  gap: 20px;
  margin: 10px;
}

.blocks {
  width: 31em;
  flex-grow: 4;
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.box {
  width: 100%;
  font-size: 1.5em;
  display: flex;
  gap: 1em;
  align-items: end;
  padding-right: 1rem;
  padding-top: 1rem;
  padding-bottom: 1rem;
  border-radius: 18px;
}

.hud-text {
  text-align: right;
  padding: 10px;
  padding-right: 15px;
  padding-left: 15px;
  font-weight: 600;
  width: 100%;
}

.leftAligned {
  text-align: left;
}

.split {
  display: flex;
  justify-content: space-between;
}

.buttons {
  font-size: 1em;
  align-items: end;
  width: fit-content;
  margin-left: auto;
  padding-left: 1em;
}
</style>
