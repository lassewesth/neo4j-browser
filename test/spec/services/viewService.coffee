'use strict'

describe 'Service: viewService', () ->

  # load the service's module
  beforeEach module 'neo4jApp.services'

  # instantiate service
  view = {}
  beforeEach inject (_viewService_) ->
    view = _viewService_
