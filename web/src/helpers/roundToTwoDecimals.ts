export const roundToTwoDecimals = (value: number): number => {
  return Math.round(value * 100) / 100;
}