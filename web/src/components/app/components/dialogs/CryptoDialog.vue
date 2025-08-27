<template>
  <Dialog >
    <DialogTrigger as-child>
      <Button
        variant="outline"
        class="w-full flex items-center justify-start sidebar-btn"
      >
      <CoinsIcon />
        {{ globalStore.baseData.data.currentCrypto }}
        {{ globalStore.baseData.data.cryptoType }}
      </Button>

    </DialogTrigger>
    <DialogContent class="dark text-foreground z-3000">
      <DialogHeader >
        <DialogTitle>{{ translate("crypto") }}</DialogTitle>
        <DialogDescription> </DialogDescription>
      </DialogHeader>
      <Tabs v-model="tab" class="mb-4">
        <TabsList>
          <TabsTrigger
            value="buy"
            v-if="globalStore.baseData.data.allowBuyingCrypto"
          >
            {{ translate("purchase") }}
          </TabsTrigger>
          <TabsTrigger
            value="sell"
            v-if="globalStore.baseData.data.allowSellingCrypto"
          >
            {{ translate("sell") }}
          </TabsTrigger>
          <TabsTrigger
            value="transfer"
            v-if="globalStore.baseData.data.allowTransferCrypto"
          >
            {{ translate("transfer") }}
          </TabsTrigger>
        </TabsList>
        <TabsContent value="buy">
          <Input
            v-model="amountBuy"
            type="number"
            :placeholder="translate('crypto_amount')"
            :aria-label="translate('crypto_amount')"
            class="dark mb-2"
          />
          <div class="text-xs text-muted-foreground mb-2">
            {{ translate("crypto_hint") }}
          </div>
          <div class="mb-2">
            {{ translate("total_cost") }}: {{ translate("currency_text")
            }}{{ amountInDollar }}
          </div>
          <Alert v-if="buyError" variant="destructive" class="mb-2">
            {{ translate(buyError) }}
          </Alert>
        </TabsContent>
        <TabsContent value="sell">
          <Input
            v-model="amountSell"
            type="number"
            :placeholder="translate('crypto_amount')"
            :aria-label="translate('crypto_amount')"
            class="mb-2"
          />
          <div class="text-xs text-muted-foreground mb-2">
            {{ translate("crypto_hint") }}
          </div>
          <div class="mb-2">
            {{ translate("total") }}: {{ translate("currency_text")
            }}{{ amountInDollarSale }}
          </div>
          <div class="mb-2">
            {{ translate("fee") }}:
            {{ globalStore.baseData.data.sellCharge * 100 }}%
          </div>
          <div class="mb-2">
            {{ translate("you_get") }}: {{ translate("currency_text")
            }}{{ amountSellAfterFee }}
          </div>
          <Alert v-if="sellError" variant="destructive" class="mb-2">
            {{ translate(sellError) }}
          </Alert>
        </TabsContent>
        <TabsContent value="transfer">
          <Input
            v-model="amountTransfer"
            type="number"
            :placeholder="translate('crypto_amount')"
            :aria-label="translate('crypto_amount')"
            class="mb-2"
          />
          <Input
            v-model="transferTo"
            :placeholder="translate('recipient_racer_name')"
            :aria-label="translate('recipient_racer_name')"
            class="mb-2"
          />
          <div class="text-xs text-muted-foreground mb-2">
            {{ translate("crypto_hint") }}
          </div>
          <Alert v-if="transferError" variant="destructive" class="mb-2">
            {{ translate(transferError) }}
          </Alert>
        </TabsContent>
      </Tabs>
      <DialogFooter>
          <Button
            v-if="tab === 'buy'"
            class="w-full"
            :disabled="!isValid"
            :loading="loadingBuy"
            @click="purchase"
          >
            {{ translate("buy") }} {{ amountBuy }}
            {{ globalStore.baseData.data.cryptoType }}
          </Button>
          <Button
            class="w-full"
            v-if="tab === 'sell'"
            :disabled="!isSaleValid"
            :loading="loadingSell"
            @click="sell"
          >
            {{ translate("sell") }} {{ amountSell }}
            {{ globalStore.baseData.data.cryptoType }}
          </Button>
          <Button
            v-if="tab === 'transfer'"
            class="w-full"
            :disabled="!isTransferValid"
            :loading="loadingTransfer"
            @click="transfer"
          >
            {{ translate("transfer") }} {{ amountTransfer }}
            {{ globalStore.baseData.data.cryptoType }}
          </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>
<script setup lang="ts">
import { translate } from "@/helpers/translate";
import { computed, Ref, ref } from "vue";
import { useGlobalStore } from "@/store/global";
import api from "@/api/axios";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Input } from "@/components/ui/input";
import { Alert } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Badge } from "@/components/ui/badge";
import { SidebarMenuButton, SidebarMenuItem } from "@/components/ui/sidebar";
import { CoinsIcon } from "lucide-vue-next";

const allowOpenRacingCrypto = computed(() => {
  return (
    globalStore.baseData.data.allowBuyingCrypto ||
    globalStore.baseData.data.allowSellingCrypto ||
    globalStore.baseData.data.allowTransferCrypto
  );
});

const globalStore = useGlobalStore();
const baseTab = globalStore.baseData.data.allowBuyingCrypto
  ? "buy"
  : globalStore.baseData.data.allowSellingCrypto
  ? "sell"
  : "transfer";

const tab = ref(baseTab);

const amountBuy = ref(0);
const amountSell = ref(0);
const amountTransfer = ref(0);
const transferTo = ref("");

const buyError: Ref<string | undefined> = ref(undefined);
const sellError: Ref<string | undefined> = ref(undefined);
const transferError: Ref<string | undefined> = ref(undefined);

const loadingBuy = ref(false);
const loadingSell = ref(false);
const loadingTransfer = ref(false);

const amountInDollar = computed(() =>
  Math.floor(amountBuy.value / globalStore.baseData.data.cryptoConversionRate)
);

const amountInDollarSale = computed(() =>
  Math.floor(amountSell.value / globalStore.baseData.data.cryptoConversionRate)
);
const amountSellAfterFee = computed(() =>
  Math.floor(
    amountInDollarSale.value -
      amountInDollarSale.value * globalStore.baseData.data.sellCharge
  )
);

const isValid = computed(() => {
  if (!(amountBuy.value >= 1 && amountInDollar.value >= 1)) return false;
  if (!Number.isInteger(amountBuy.value)) return false;
  return true;
});

const isSaleValid = computed(() => {
  if (amountSell.value > globalStore.baseData.data.currentCrypto) return false;
  if (!(amountSell.value >= 1 && amountInDollarSale.value >= 1)) return false;
  if (!Number.isInteger(amountSell.value)) return false;
  return true;
});

const isTransferValid = computed(() => {
  if (amountTransfer.value > globalStore.baseData.data.currentCrypto)
    return false;
  if (!(amountTransfer.value >= 1)) return false;
  if (!Number.isInteger(amountTransfer.value)) return false;

  return true;
});

const isTransferToValid = computed(() => {
  if (transferTo.value.length === 0) return false;

  return true;
});

const purchase = async () => {
  loadingBuy.value = true;
  const result = await api.post(
    "UiPurchaseCrypto",
    JSON.stringify({ cryptoAmount: amountBuy.value })
  );
  if (result.data !== "SUCCESS") {
    buyError.value = result.data;
  } else {
    buyError.value = undefined;
  }

  loadingBuy.value = false;
};

const sell = async () => {
  loadingSell.value = true;
  const result = await api.post(
    "UiSellCrypto",
    JSON.stringify({ cryptoAmount: amountSell.value })
  );
  if (result.data !== "SUCCESS") {
    sellError.value = result.data;
  } else {
    sellError.value = undefined;
  }
  loadingSell.value = false;
};

const transfer = async () => {
  loadingTransfer.value = true;
  const result = await api.post(
    "UiTransferCrypto",
    JSON.stringify({
      cryptoAmount: amountTransfer.value,
      recipient: transferTo.value,
    })
  );

  if (result.data !== "SUCCESS") {
    transferError.value = result.data;
  } else {
    transferError.value = undefined;
  }
  loadingTransfer.value = false;
};
</script>

<style scoped>
.header {
  margin-bottom: 1em;
}
</style>
