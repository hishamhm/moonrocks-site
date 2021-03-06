import time_ago_in_words from require "lapis.util"

import escape from require "lapis.html"

basic_format = do
  import P, R, C, Cs, S, Cmt, Ct, Cg from require "lpeg"
  stop = P"\r"^-1 * P"\n"

  char = stop / "<br />" + 1

  paragraph_body = Cs (char - stop * stop)^1
  paragraphs = Ct paragraph_body * (stop^1 * paragraph_body)^0

  (str) ->
    str = escape str
    body = if ps = paragraphs\match str
      table.concat(ps, "</p><p>")
    else
      str

    "<p>#{body}</p>"

class Module extends require "widgets.base"
  inner_content: =>
    @admin_panel!

    div class: "module_header", ->
      h2 @module\name_for_display!
      if summary = @module.summary
        p summary

    div class: "metadata_columns", ->
      div class: "column", ->
        h3 "Uploader"
        user_url = @url_for "user_profile", user: @user.slug
        a href: user_url, -> img class: "avatar", src: @user\gravatar(20)
        a href: user_url, @user.username

      div class: "column", ->
        if license = @module.license
          h3 "License"
          text license

      div class: "column", ->
        if url = @module\format_homepage_url!
          h3 "Homepage"
          a class: "external_url", href: url, @truncate url, 60

    if description = @module.description
      h3 "About"
      div class: "description", ->
        raw basic_format description

    h3 "Versions"
    for v in *@versions
      div class: "version_row", ->
        url = "/modules/#{@user.slug}/#{@module.name}/#{v.version_name}"
        a href: url, v\name_for_display!

        if v.development
          span class: "development_flag", "dev"

        span class: "sub", title: "#{v.created_at} UTC", time_ago_in_words(v.created_at)

    if @dependencies and next @dependencies
      h3 "Dependencies"
      for d in *@dependencies
        div class: "dependency_row", ->
          code d.dependency

    can_edit = @module\allowed_to_edit @current_user
    if next @manifests
      h3 "Manifests"
      for m in *@manifests
        @manifest = m
        div class: "manifest_row", ->
          a href: @url_for("manifest", @), ->
            code m.name

          if can_edit
            span class: "sub", ->
              text " ("
              a href: @url_for("remove_from_manifest", @), "remove"
              text ")"

        @manifest = nil

  admin_panel: =>
    return unless @module\allowed_to_edit @current_user
    div class: "admin_tools", ->
      span class: "label", ->
        if @current_user\is_admin!
          text "Admin Tools: "
        else
          text "Owner Tools: "

      a href: @url_for("add_to_manifest", @), "Add To Manifest"
      raw " &middot; "
      a href: @url_for("edit_module", @), "Edit"
      raw " &middot; "
      a href: @url_for("delete_module", @), "Delete"

      if @current_user\is_admin!
        raw " &middot; "
        a href: @url_for("copy_module", @), "Copy module to other user"



