HomeController = ($scope, $http) ->

angular.module('badgr', [])
  .config([ '$routeProvider', '$locationProvider', '$httpProvider', ($routeProvider, $locationProvider, $httpProvider) ->
    $routeProvider.when('/',
      templateUrl: '/static/partials/home.html'
      controller: HomeController
    ).otherwise redirectTo: '/'
  ])