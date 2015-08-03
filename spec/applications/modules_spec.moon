import use_test_server from require "lapis.spec"
import truncate_tables from require "lapis.spec.db"

import request_as from require "spec.helpers"

factory = require "spec.factory"


import Modules, Versions, Followings, Users from require "models"

describe "applications.modules", ->
  use_test_server!

  before_each ->
    truncate_tables Modules, Versions, Followings, Users

  it "follows module", ->
    current_user = factory.Users!
    mod = factory.Modules!
    status, res = request_as current_user, "/module/#{mod.id}/follow"
    assert.same 302, status

    followings = Followings\select!

    assert.same 1, #followings
    following = unpack followings

    assert.same current_user.id, following.source_user_id
    assert.same Followings.object_types.module, following.object_type
    assert.same mod.id, following.object_id

  it "unfollows module", ->
    following = factory.Followings!
    mod = following\get_object!

    status, res = request_as following\get_source_user!, "/module/#{mod.id}/unfollow"
    assert.same 302, status

    followings = Followings\select!
    assert.same 0, #followings
