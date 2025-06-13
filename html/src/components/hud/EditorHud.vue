<template>
  <div class="editor">
    <div class="editor__container">
      <!-- Track Info -->
      <div class="editor__panel">
        <div class="info-list">
          <div class="info-item">
            <div class="info-label">
              <v-icon icon="mdi-map-marker" size="small" class="info-icon"></v-icon>
              <span>{{ translate("track_name") }}</span>
            </div>
            <span class="info-value">{{ globalStore.creatorData.RaceName }}</span>
          </div>
          <div class="info-item">
            <div class="info-label">
              <v-icon icon="mdi-flag-checkered" size="small" class="info-icon"></v-icon>
              <span>{{ translate("checkpoints") }}</span>
            </div>
            <span class="info-value">{{ globalStore.creatorData.Checkpoints?.length || 0 }}</span>
          </div>
          <div class="info-item">
            <div class="info-label">
              <v-icon icon="mdi-crosshairs-gps" size="small" class="info-icon"></v-icon>
              <span>{{ translate("closest_checkpoint") }}</span>
            </div>
            <span class="info-value">{{ globalStore.creatorData.ClosestCheckpoint || "-" }}</span>
          </div>
        </div>
      </div>

      <!-- Controls -->
      <div class="editor__panel">
        <div class="controls-list">
          <!-- Main Controls -->
          <div class="control-item">
            <span class="key success-key">{{ globalStore.buttons.AddCheckpoint }}</span>
            <span class="control-label">{{ translate("add_checkpoint") }}</span>
          </div>
          
          <div class="control-item" v-if="globalStore.creatorData.ClosestCheckpoint">
            <span class="key danger-key">{{ globalStore.buttons.DeleteCheckpoint }}</span>
            <span class="control-label">{{ translate("delete_checkpoint") }} {{ globalStore.creatorData.ClosestCheckpoint }}</span>
          </div>
          
          <div class="control-item">
            <span class="key info-key">{{ globalStore.buttons.MoveCheckpoint }}</span>
            <span class="control-label">{{ translate("modify_checkpoint") }}</span>
          </div>

          <!-- Distance Control -->
          <div class="control-item distance">
            <div class="distance-group">
              <span class="key danger-key">{{ globalStore.buttons.DecreaseDistance }}</span>
              <span class="key info-key">{{ globalStore.buttons.IncreaseDistance }}</span>
            </div>
            <div class="control-label">
              <span>{{ translate("tire_distance") }}</span>
              <span class="distance-value">[{{ globalStore.creatorData.TireDistance }}]</span>
            </div>
          </div>

          <!-- Actions -->
          <div class="actions-group">
            <div class="control-item">
              <span class="key danger-key">{{ globalStore.buttons.Exit }}</span>
              <span class="control-label">{{ translate("close_editor") }}</span>
            </div>
            <div class="control-item">
              <span class="key success-key">{{ globalStore.buttons.SaveRace }}</span>
              <span class="control-label">{{ translate("save_track") }}</span>
            </div>
          </div>
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
@import '@/styles/variables.scss';

.editor {
  position: fixed;
  top: 1vh;
  right: 1vw;
  z-index: 10;
}

.editor__container {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  max-width: 350px;
}

.editor__panel {
  background: rgba($background-color-dark, 0.8);
  backdrop-filter: blur(8px);
  border-radius: $border-radius;
  padding: 0.6rem;
}

.info-list {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  padding: 0.2rem 0;

  .info-label {
    display: flex;
    align-items: center;
    gap: 0.4rem;
    color: rgba($text-color, 0.7);
    font-size: 0.8rem;

    .info-icon {
      color: $primary-color;
      opacity: 0.8;
    }
  }

  .info-value {
    color: $text-color;
    font-size: 0.8rem;
    font-weight: 500;
  }
}

.controls-list {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.control-item {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  padding: 0.2rem 0;

  &.distance {
    .distance-group {
      display: flex;
      gap: 0.3rem;
    }

    .distance-value {
      color: $primary-color;
      margin-left: 0.3rem;
    }
  }
}

.control-label {
  color: rgba($text-color, 0.8);
  font-size: 0.8rem;
  display: flex;
  align-items: center;
  gap: 0.3rem;
}

.key {
  background: rgba($background-color-lighter, 0.3);
  color: $text-color;
  padding: 0.15rem 0.4rem;
  border-radius: $border-radius;
  font-size: 0.75rem;
  min-width: 1.5rem;
  text-align: center;
  border: 1px solid rgba($text-color, 0.1);
  transition: all 0.2s ease;

  &.success-key {
    background: rgba($positive-color, 0.15);
    border-color: rgba($positive-color, 0.3);
    color: $positive-color;
  }

  &.danger-key {
    background: rgba($negative-color, 0.15);
    border-color: rgba($negative-color, 0.3);
    color: $negative-color;
  }

  &.info-key {
    background: rgba($primary-color, 0.15);
    border-color: rgba($primary-color, 0.3);
    color: $primary-color;
  }

  &:hover {
    transform: translateY(-1px);
    filter: brightness(1.1);
  }
}

.actions-group {
  margin-top: 0.4rem;
  padding-top: 0.4rem;
  border-top: 1px solid rgba($text-color, 0.1);
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

// Simple fade transition
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>

