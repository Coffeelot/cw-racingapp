export const secondsToHMS = (input: number) => {
    const milliseconds = input % 1000;
    const seconds = Math.floor((input / 1000) % 60);
    const minutes = Math.floor((input / (60 * 1000)) % 60);
    const minutesString = (minutes < 10) ? "0" + minutes : minutes;
    const secondsString = (seconds < 10) ? "0" + seconds : seconds;

    return minutesString + ":" + secondsString + "." + String(milliseconds).slice(0,2);
}