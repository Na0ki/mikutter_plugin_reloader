# -*- coding: utf-8 -*-
# -*- frozen_string_literal: true -*-

Plugin.create(:plugin_reloader) do
  # 初期化
  def initialize
    notice 'plugin_reloader loaded'
  end

  def solve_slug(slug)
    if slug.nil? || slug.empty? || slug == self.name
      throw InvalidSlugError('slug is not acceptable')
    end
    slug.to_sym
  rescue InvalidSlugError => e
    error e
  end

  def detach(slug)
    type_strict slug => Symbol
    Plugin[slug].uninstall
  end

  def attach(slug)
    type_strict slug => Symbol
    Miquire::Plugin.load(slug)
  end

  def reload(slug)
    type_strict slug => Symbol
    Thread.new {
      detach(slug)
    }.next {
      attach(slug)
    }.trap { |e| error e }
  end

  on_plugin_detach do |slug|
    detach(slug)
  end

  on_plugin_attach do |slug|
    attach(slug)
  end

  on_plugin_reload do |slug|
    detach(slug)
    attach(slug)
  end

  command(:plugin_reloader_detach,
          name:      'プラグインを外す',
          condition: ->(_) { true },
          visible:   true,
          role:      :postbox) do |opt|
    # postboxからメッセージを取得
    post_widget = Plugin.create(:gtk).widgetof(opt.widget).widget_post
    slug = solve_slug(post_widget.buffer.text)
    detach(slug)
    post_widget.buffer.text = ''
  end

  command(:plugin_reloader_attach,
          name:      'プラグインをロードする',
          condition: ->(_) { true },
          visible:   true,
          role:      :postbox) do |opt|
    # postboxからメッセージを取得
    post_widget = Plugin.create(:gtk).widgetof(opt.widget).widget_post
    slug = solve_slug(post_widget.buffer.text)
    if attach(slug)
      post_widget.buffer.text = ''
    end
  end

  command(:plugin_reloader_reload,
          name:      'プラグインをリロードする',
          condition: ->(_) { true },
          visible:   true,
          role:      :postbox) do |opt|
    # postboxからメッセージを取得
    post_widget = Plugin.create(:gtk).widgetof(opt.widget).widget_post
    slug = solve_slug(post_widget.buffer.text)
    if reload(slug)
      post_widget.buffer.text = ''
    end
  end
end

class InvalidSlugError < StandardError
end
