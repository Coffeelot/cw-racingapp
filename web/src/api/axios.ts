import axios, { type AxiosInstance } from "axios";

// change the baseURL to whatever your resource is called
// example -> baseURL: "https://<resource_name_here>/"
// connection has to be secure ( HTTPS )
const api: AxiosInstance = axios.create({
	baseURL: "https://cw-racingapp/",
});

export default api;
