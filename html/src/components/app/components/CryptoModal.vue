<template>
  <v-dialog
    attach=".app-container"
    contained
    width="auto"
    v-model="globalStore.showCryptoModal"
  >
    <v-card
      class="mx-auto" 
      rounded="lg"
      :title="
        translate('purchase') + ' ' + globalStore.baseData.data.cryptoType
      "
      :subtitle="
        translate('current_conversionrate') +
        ': 1' +
        globalStore.baseData.data.cryptoType +
        ' = ' +
        translate('currency_text') +
        1 / globalStore.baseData.data.cryptoConversionRate
      "
    >
    <v-tabs
      v-model="tab"
    >
      <v-tab value="buy" v-if="globalStore.baseData.data.allowBuyingCrypto">{{ translate('buy') }}</v-tab>
      <v-tab value="sell" v-if="globalStore.baseData.data.allowSellingCrypto">{{ translate('sell') }}</v-tab>
      <v-tab value="transfer" v-if="globalStore.baseData.data.allowTransferCrypto">{{ translate('transfer') }}</v-tab>
    </v-tabs>
      <v-card-text>
        <v-tabs-window v-model="tab">
        <v-tabs-window-item value="buy">
          <v-text-field
          v-model.number="amountBuy"
          :error="!isValid"
          :hint="translate('crypto_hint')"
          hide-details="auto"
          :label="translate('crypto_amount')"
          persistent-hint
          type="number"
        ></v-text-field>
        <p class="mt-1">
          {{ translate("total_cost") }}: {{ translate("currency_text")
          }}{{ amountInDollar }}
        </p>
        <v-alert class="mt-1" type="error" v-if="buyError">{{ translate(buyError) }}</v-alert>
        <p class="mt-1">
          <v-btn
          rounded="xl"
          block
          color="success"
          variant="flat"
          :disabled="!isValid"
          :loading="loadingBuy"
          :text="translate('buy') +' '+  amountBuy + ' '+ globalStore.baseData.data.cryptoType"
          @click="purchase"
        ></v-btn>
        </p>
        </v-tabs-window-item>

        <v-tabs-window-item value="sell">
          <v-text-field
              v-model.number="amountSell"
              :error="!isSaleValid"
              :hint="translate('crypto_hint')"
              hide-details="auto"
              :label="translate('crypto_amount')"
              persistent-hint
              type="number"
            ></v-text-field>
            <p class="mt-1">
              {{ translate("total") }}: {{ translate("currency_text")
              }}{{ amountInDollarSale }}
            </p>
            <p>
              {{ translate("fee") }}:  {{ globalStore.baseData.data.sellCharge*100 }}%  
            </p>
            <p>
              {{ translate("you_get") }}: {{ translate("currency_text") }}{{ amountSellAfterFee }}
            </p>
            <v-alert class="mt-1" type="error" v-if="sellError">{{ translate(sellError) }}</v-alert>

            <p class="mt-1">
              <v-btn
                block
                rounded="xl"
                color="success"
                variant="flat"
                :disabled="!isSaleValid"
                :loading="loadingSell"

                :text="translate('sell') + ' ' + amountSell + ' '+ globalStore.baseData.data.cryptoType"
                @click="sell"
              ></v-btn>
            </p>
        </v-tabs-window-item>

        <v-tabs-window-item value="transfer">
          <v-text-field
              v-model.number="amountTransfer"
              :error="!isTransferValid"
              hide-details="auto"
              :label="translate('crypto_amount')"
              type="number"
          ></v-text-field>
          <v-text-field
              v-model="transferTo"
              :error="!isTransferToValid"
              :hint="translate('crypto_hint')"
              hide-details="auto"
              :label="translate('recipient_racer_name')"
              persistent-hint
          ></v-text-field>
          <v-alert class="mt-1" type="error" v-if="transferError">{{ translate(transferError) }}</v-alert>
            <p class="mt-1">
              <v-btn
                block
                rounded="xl"
                color="success"
                variant="flat"
                :loading="loadingTransfer"
                :disabled="!isTransferValid"
                :text="translate('transfer') + ' ' + amountTransfer + ' '+ globalStore.baseData.data.cryptoType"
                @click="transfer"
              ></v-btn>
            </p>
        </v-tabs-window-item>
      </v-tabs-window>

      </v-card-text>
      <v-card-actions>
        <v-spacer></v-spacer>
        <v-btn
          variant="text"
          :text="translate('close')"
          @click="globalStore.showCryptoModal = false"
        ></v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
<script setup lang="ts">
import { translate } from "@/helpers/translate";
import { computed, Ref, ref } from "vue";
import { useGlobalStore } from "@/store/global";
import api from "@/api/axios";

const globalStore = useGlobalStore();
const baseTab = globalStore.baseData.data.allowBuyingCrypto ? 'buy': (globalStore.baseData.data.allowSellingCrypto ? 'sell':'transfer' )

const tab = ref(baseTab);

const amountBuy = ref(0);
const amountSell = ref(0);
const amountTransfer = ref(0)
const transferTo = ref('')

const buyError: Ref<string | undefined> = ref(undefined)
const sellError: Ref<string | undefined> = ref(undefined)
const transferError: Ref<string | undefined> = ref(undefined)

const loadingBuy = ref(false)
const loadingSell = ref(false)
const loadingTransfer = ref(false)

const amountInDollar = computed(() =>
  Math.floor(amountBuy.value / globalStore.baseData.data.cryptoConversionRate)
);

const amountInDollarSale = computed(() => Math.floor(amountSell.value/globalStore.baseData.data.cryptoConversionRate))
const amountSellAfterFee = computed(() => Math.floor(amountInDollarSale.value - amountInDollarSale.value*globalStore.baseData.data.sellCharge))



const isValid = computed(() => {
  if (!(amountBuy.value >= 1 && amountInDollar.value >= 1)) return false;
  if (!Number.isInteger(amountBuy.value)) return false;
  return true;
});

const isSaleValid = computed(() => {
  if (amountSell.value > globalStore.baseData.data.currentCrypto) return false
  if (!(amountSell.value >= 1 && amountInDollarSale.value >= 1)) return false;
  if (!Number.isInteger(amountSell.value)) return false;
  return true;
});

const isTransferValid = computed(() => {
  if (amountTransfer.value > globalStore.baseData.data.currentCrypto) return false
  if (!(amountTransfer.value >= 1)) return false;
  if (!Number.isInteger(amountTransfer.value)) return false;

  return true;
});

const isTransferToValid = computed(() => {
  if (transferTo.value.length === 0) return false;

  return true;
});

const purchase = async () => {
  loadingBuy.value = true
  const result = await api.post('UiPurchaseCrypto', JSON.stringify({ cryptoAmount: amountBuy.value }))
  if (result.data !== 'SUCCESS') {
    buyError.value = result.data
  } else {
    buyError.value = undefined
  }

  loadingBuy.value = false
}

const sell = async () => {
  loadingSell.value = true
  const result = await api.post('UiSellCrypto', JSON.stringify({ cryptoAmount: amountSell.value }))
  if (result.data !== 'SUCCESS') {
    sellError.value = result.data
  } else {
    sellError.value = undefined
  }
  loadingSell.value = false
}

const transfer = async () => {
  loadingTransfer.value = true
  const result = await api.post('UiTransferCrypto', JSON.stringify({ cryptoAmount: amountTransfer.value, recipient: transferTo.value }))

  if (result.data !== 'SUCCESS') {
    transferError.value = result.data 
  } else {
    transferError.value = undefined
  }
  loadingTransfer.value = false
}

</script>

<style scoped lang="scss">
.header {
  margin-bottom: 1em;
}
</style>
