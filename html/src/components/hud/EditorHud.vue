<template>
  <div class="editor">
    <div class="blocks-container">
      <div class="blocks">
        <div class="box editor-holder">
          <span class="editor-text" id="editor-racename"
            >Track Name: {{ globalStore.creatorData.RaceName }}</span
          >
          <span class="editor-text" id="editor-checkpoints"
            >Checkpoints: {{ globalStore.creatorData.Checkpoints? globalStore.creatorData.Checkpoints.length: 0 }}</span
          >
        </div>
        <div class="box editor-holder">
          <span class="editor-text" id="editor-keys-add"
            ><span id="editor-keys-add-button" style="color: rgb(0, 201, 0)">{{
             globalStore.buttons.AddCheckpoint
            }}</span>
            - Add Checkpoint</span
          >
          <span class="editor-text" id="editor-keys-delete" v-if="globalStore.activeHudData.ClosestCheckpoint">
            <span style="color: rgb(255, 43, 43);">{{globalStore.buttons.DeleteCheckpoint }}</span> - Delete Checkpoint {{ globalStore.activeHudData.ClosestCheckpoint }}
          </span>
          <span class="editor-text" id="editor-keys-edit"
            ><span id="editor-keys-edit-button" style="color: rgb(0, 201, 0)">{{
             globalStore.buttons.MoveCheckpoint
            }}</span
            >- Modify Checkpoint Menu</span
          >
          <span class="editor-text" id="editor-keys-tiredistance">
            <span style="margin-right: 0.5em; color: rgb(255, 43, 43)">{{
              globalStore.buttons.DecreaseDistance
            }}</span>
            <span style="color: rgb(0, 201, 0)">
              {{globalStore.buttons.IncreaseDistance }}
            </span>
            Tire Distance: {{ globalStore.creatorData.TireDistance }}
          </span>
          <span class="editor-text" id="editor-keys-cancel"
            ><span
              id="editor-keys-cancel-button"
              style="color: rgb(255, 43, 43)"
              >{{globalStore.buttons.Exit }}</span
            >
            - Cancel Editor</span
          >
          <span class="editor-text" id="editor-keys-save"
            ><span id="editor-keys-save-button" style="color: rgb(0, 201, 0)">{{
             globalStore.buttons.SaveRace
            }}</span>
            - Save Race</span
          >
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useGlobalStore } from "@/store/global";

const globalStore = useGlobalStore();
</script>

<style scoped lang="scss">
.editor  {
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
  background: $hud-background;
  width: 100%;
  font-size: 1.5em;
  display: flex;
  gap: 1em;
  align-items: center;
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

</style>
