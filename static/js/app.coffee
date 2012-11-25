HomeController = ($scope, $http, $cookies) ->
  $http.get('/user').success (user) -> $scope.user = user

angular.module('badgr', ['ngCookies'])
  .config([ '$routeProvider', '$locationProvider', '$httpProvider', ($routeProvider, $locationProvider, $httpProvider) ->
    $routeProvider.when('/',
      templateUrl: '/partials/home.html'
      controller: HomeController
    ).otherwise redirectTo: '/'
    $locationProvider.html5Mode true
  ])