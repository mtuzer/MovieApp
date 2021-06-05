![Swift Version][swift-image] ![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)

# MovieApp
*This app shows a list of popular movies fetched from [The Movie Database (TMDB) API](https://developers.themoviedb.org/3/getting-started/introduction) and shows the detail of the movie when selected.*

<p align="center">
<img src= "https://raw.githubusercontent.com/mtuzer/MovieApp/master/Main.png" width="200" >
<img src= "https://raw.githubusercontent.com/mtuzer/MovieApp/master/Detail.png" width="200" >
</p>

## Features

- [x] MVVM-based Application: 'Interactor' instead of ViewModel
- [x] Protocol Oriented
- [x] No 3rd Party Libraries
- [x] Covered by Unit Tests


In this project, Interactors are responsible for receiving actions from Views and calling necessary network requests, or doing other business logic operations, and then presenting ViewModels, throwing errors, or giving navigation routes to the related Views. 
ViewModels, instead of being responsible for the business logic, are only simple presentation models to be used in business-agnostic Views.

## Note:
Add your own API key from the TMDB API.


[swift-image]:https://img.shields.io/badge/swift-5.0-orange.svg
