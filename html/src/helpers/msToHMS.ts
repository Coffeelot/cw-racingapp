export const msToHMS = (input: number) => {
    const totalMilliseconds = input;
    const seconds = Math.floor(totalMilliseconds / 1000);
    const minutes = Math.floor(seconds / 60);
    const secondsRemaining = seconds % 60;
    const millisecondsRemaining = totalMilliseconds % 1000;
  
    const minutesString = String(minutes).padStart(2, '0');
    const secondsString = String(secondsRemaining).padStart(2, '0');
    const millisecondsString = String(millisecondsRemaining).padStart(3, '0');
  
    return `${minutesString}:${secondsString}.${millisecondsString}`;
}