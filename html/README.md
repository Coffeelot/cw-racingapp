<p align="center">
    <a href="https://github.com/alenvalek/fivem-vuejs-boilerplate">
        <img src="https://i.ibb.co/NrJDyC2/Five-M-Vue-JS-Boilerplate.png" alt="FiveM VueJS Boilerplate"/>
    </a>
</p>

<h4 align="center">FiveM VueJS Boilerplate for building beautiful NUI-s without hassle of setting everything up</h4>

<p align="center">
    <img alt="GitHub package.json version (subfolder of monorepo)" src="https://img.shields.io/github/package-json/v/alenvalek/fivem-vuejs-boilerplate?filename=html%2Fpackage.json">
    <img alt="GitHub" src="https://img.shields.io/github/license/alenvalek/fivem-vuejs-boilerplate">
    <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/alenvalek/fivem-vuejs-boilerplate">
    <img alt="Maintenance" src="https://img.shields.io/maintenance/yes/2022">
</p>
<p align="center">
<img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/alenvalek/fivem-vuejs-boilerplate?style=social">
    <img alt="GitHub forks" src="https://img.shields.io/github/forks/alenvalek/fivem-vuejs-boilerplate?style=social">
</p>
<hr>

FiveM VueJS Boilerplate is a template for making your own NUI-s for FiveM using VueJS. It removes the hassle of setting everything up on your own and constantly dealing with errors and mistakes before you finally get it up and running. VueJS allows you to build out your NUI-s faster and it eases the logic implementation. With this boilerplate all you have to do is let your mind go wild and free on a creative spree and start making your own interface designs.
<hr>

## Key features
* Vuex pre-implemented with examples of usage
* Vuetify pre-implemented with examples of usage
* Axios pre-implemented with examples of usage
* Client code pre-implemented with examples of usage
* Watch script pre-implemented for building out the site for ui_view in-game
<hr>

## Installation
Download the zip files or clone the repository:
```bash
git clone https://github.com/alenvalek/fivem-vuejs-boilerplate.git
```
Open the project in a terminal of your choice and change the working directory into the html folder:
```bash
cd ./html
```
Install the required node packages
```bash
npm install
```

After that you can modify the api file inside html/api/axios.js in case you're planning to rename the resource. \
After that you are ready to start building out your dream NUI.


### Development tips
Run the following command to develop using a live server ( in browser )
```bash
npm run serve
```
Run the following command to build out your project for use in game
```bash
npm run build
```
Run the following command to build out the project for use in game every time a change has occured ( keep in mind you still have to restart the resource on your server for the changes to take effect ) **[RECOMMENDED]**
```bash
npm run watch
```
<hr>

## Technologies
* [Lua](https://www.lua.org)
* [VueJS](https://vuejs.org)
* [VuetifyJS](https://vuetifyjs.com/en/)
* [Vuex](https://vuex.vuejs.org)

## Contributing
If you want to contribute to a project and make it better, every help is welcome.
### How to contribute
1. **Fork** the repo to your own personal GitHub
2. **Clone** the project to your own machine
3. **Commit** changes to your own branch
4. **Push** your work to your own branch
5. Submit a **pull** request so changes can be reviewed before the merge 

NOTE: Be sure to merge the latest from "upstream" before making a merge request.

## License and license summary
FiveM BoilerPlate is licensed under **MIT License**

```
MIT License

Copyright (c) 2022 Alen Valek

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```