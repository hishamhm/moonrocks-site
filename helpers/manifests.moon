
import insert, concat from table
import get_all_pages from require "helpers.models"

persist = require "ext.luarocks.persist"

import
  Versions
  Rocks
  from require "models"

default_table = ->
  setmetatable {}, __index: (key) =>
    with t = {} do @[key] = t

render_manifest = (modules) =>
  mod_ids = [mod.id for mod in *modules]

  repository = {}
  if next mod_ids
    mod_ids = concat mod_ids, ", "
    versions = get_all_pages Versions\paginated "where module_id in (#{mod_ids}) order by id", per_page: 50

    module_to_versions = default_table!
    version_to_rocks = default_table!

    version_ids = [v.id for v in *versions]
    if next version_ids
      version_ids = concat version_ids, ", "
      rocks = get_all_pages Rocks\paginated "where version_id in (#{version_ids}) order by id", per_page: 50
      for rock in *rocks
        insert version_to_rocks[rock.version_id], rock

    for v in *versions
      insert module_to_versions[v.module_id], v

    for mod in *modules
      vtbl = {}

      for v in *module_to_versions[mod.id]
        rtbl = {}
        insert rtbl, arch: "rockspec"
        for rock in *version_to_rocks[v.id]
          insert rtbl, arch: rock.arch

        vtbl[v.version_name] = rtbl

      repository[mod.name] = vtbl

  commands = {}
  modules = {}

  @res.headers["Content-type"] = "text/x-lua"
  layout: false, persist.save_from_table_to_string {
    :repository, :commands, :modules
  }


{ :render_manifest }