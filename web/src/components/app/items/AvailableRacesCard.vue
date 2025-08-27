<template>
  <Card
    class="available-card rounded-xl border h-fit"
    v-if="!hasExpired && !props.race.RaceData.Started"
  >
    <CardHeader>
      <CardTitle>
        <div class="flex gap-2 items-center">
          <span>{{ props.race.TrackData.RaceName }}</span>
          <Badge variant="outline" class="flex items-center gap-1">
            <ClockIcon />
            {{
              props.race.Automated
                ? translate("starts_in")
                : `${translate("expires")}:`
            }}
            {{ minutes }}:{{ seconds }}
          </Badge>
        </div>
        <CardDescription>
          {{ translate("hosted_by") }} {{ props.race.SetupRacerName }}
        </CardDescription>
      </CardTitle>
    </CardHeader>
    <CardContent class="inline standardGap flex flex-wrap gap-2">
      <Badge
        variant="outline"
        v-if="props.race?.Ranked"
        class="bg-orange-500 text-white flex items-center gap-1"
      >
        <RankedIcon />
        {{ translate("ranked") }}
      </Badge>

      <TooltipProvider v-if="props.race.ParticipationAmount">
        <Tooltip>
          <TooltipTrigger as-child>
            <Badge
              variant="outline"
              class="bg-green-500 text-white flex items-center gap-1"
            >
              <HandCoins />
              {{ participationText }}
            </Badge>
          </TooltipTrigger>
          <TooltipContent>
            <p>{{ translate("participation_info") }}</p>
          </TooltipContent>
        </Tooltip>
      </TooltipProvider>
      <Badge variant="outline" class="flex items-center gap-1">
        <TrackIcon />
        {{ `${lapsText} ${props.race.TrackData.Distance} m` }}
      </Badge>
      <Badge variant="outline" v-if="buyInText" class="flex items-center gap-1">
        <CoinsIcon />
        {{ buyInText }}
      </Badge>
      <Badge
        variant="outline"
        v-if="potText && props.race.racers > 1"
        class="flex items-center gap-1"
      >
        <TotalIcon />
        {{ potText }}
      </Badge>
      <Badge variant="outline" class="flex items-center gap-1">
        <UsersIcon />
        {{ `${props.race.racers} ${translate("racers")}` }}
      </Badge>
      <Badge
        variant="outline"
        v-if="props.race.MaxClass"
        class="flex items-center gap-1"
      >
        <InfoIcon />
        {{ `${translate("class")}: ${props.race.MaxClass}` }}
      </Badge>
      <Badge
        variant="outline"
        v-if="props.race.Ghosting"
        class="flex items-center gap-1"
      >
        <GhostIcon />
        {{ ghostingText }}
      </Badge>
      <Badge
        variant="outline"
        v-if="props.race.FirstPerson"
        class="flex items-center gap-1"
      >
        <EyeIcon />
        {{ translate("first_person") }}
      </Badge>
      <Badge
        variant="outline"
        v-if="props.race.Reversed"
        class="flex items-center gap-1"
      >
        <RotateCcw />
        {{ translate("reversed") }}
      </Badge>
    </CardContent>
    <CardFooter v-if="!props.race.disabled" class="flex gap-2 justify-end">
      <Button variant="ghost" @click="showRace()">
        {{ translate("show_track") }}
      </Button>
      <Button color="primary" @click="joinRace()">
        {{ translate("join_race") }}
      </Button>
    </CardFooter>
  </Card>
</template>

<script setup lang="ts">
import api from "@/api/axios";
import { closeApp } from "@/helpers/closeApp";
import { useGlobalStore } from "@/store/global";
import { translate } from "@/helpers/translate";
import { computed, onMounted, onUnmounted, ref } from "vue";
import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import CardDescription from "@/components/ui/card/CardDescription.vue";
import {
  ClockIcon,
  CoinsIcon,
  EyeIcon,
  HandCoins,
  InfoIcon,
  RotateCcw,
  UsersIcon,
} from "lucide-vue-next";
import RankedIcon from "@/assets/icons/RankedIcon.vue";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import TrackIcon from "@/assets/icons/TrackIcon.vue";
import TotalIcon from "@/assets/icons/TotalIcon.vue";
import GhostIcon from "@/assets/icons/GhostIcon.vue";

const props = defineProps<{
  race: any;
}>();
const globalStore = useGlobalStore();

const joinRace = async () => {
  const res = await api.post("UiJoinRace", JSON.stringify(props.race.RaceId));
  if (res.data) closeApp();
};

const participationText = computed(() => {
  if (props.race.ParticipationCurrency === "racingcrypto") {
    return (
      props.race.ParticipationAmount +
      " " +
      globalStore.baseData.data.payments.cryptoType
    );
  }

  return "$" + props.race.ParticipationAmount;
});

const lapsText = computed(() => {
  let lapsText = "Sprint | ";
  if (props.race.laps == -1) {
    lapsText = "Elimination | ";
  } else if (props.race.laps > 0) {
    lapsText = props.race.Laps + " " + translate("laps") + " | ";
  }
  return lapsText;
});

const buyInText = computed(() => {
  let text = undefined;
  if (props.race.BuyIn > 0) {
    if (globalStore.baseData.data.payments.racing === "racingcrypto") {
      text =
        props.race.BuyIn +
        " " +
        globalStore.baseData.data.payments.cryptoType +
        " " +
        translate("buy_in");
    } else {
      text = "$" + props.race.BuyIn + " " + translate("buy_in");
    }
  }
  return text;
});

const potText = computed(() => {
  let text = undefined;
  if (props.race.BuyIn > 0) {
    text = translate("pot") + ": " + props.race.racers * props.race.BuyIn;
  }
  return text;
});

const ghostingText = computed(() => {
  let ghostingText = "";
  if (props.race.Ghosting) {
    ghostingText = translate("active");
    if (props.race.GhostingTime) {
      ghostingText = props.race.GhostingTime + "s)";
    }
  }
  return ghostingText;
});

const showRace = async () => {
  const res = await api.post("UiShowTrack", JSON.stringify(props.race.TrackId));
  if (res.data) closeApp();
};

const futureTimestamp = ref<number>(props.race.ExpirationTime);

const remainingTime = ref<number>(
  futureTimestamp.value
    ? futureTimestamp.value - Math.floor(Date.now() / 1000)
    : 0
);

const minutes = computed(() =>
  Math.floor(remainingTime.value / 60)
    .toString()
    .padStart(2, "0")
);
const seconds = computed(() =>
  (remainingTime.value % 60).toString().padStart(2, "0")
);

const hasExpired = computed(() => remainingTime.value <= 0);

const startCountdown = () => {
  if (futureTimestamp.value) {
    const interval = setInterval(() => {
      remainingTime.value -= 1;
      if (remainingTime.value <= 0) {
        remainingTime.value = 0;
        clearInterval(interval);
      }
    }, 1000);

    onUnmounted(() => {
      startCountdown();
      clearInterval(interval);
    });
  }
};

onMounted(() => {
  startCountdown();
});
</script>

<style scoped>
.available-card {
  width: 100%;
  max-width: 30em;
}
</style>
