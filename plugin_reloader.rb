# -*- coding: utf-8 -*-
# -*- frozen_string_literal: true -*-

Plugin.create(:plugin_reloader) do
  # 初期化
  def initialize
    notice 'plugin_reloader loaded'
  end

  def detach(slug)
    slug.slice(/^:/) if slug[0] == ':'
    Plugin.uninstall(:"#{slug}")
  end

  def attach(slug)
    slug.slice(/^:/) if slug[0] == ':'
    Miquire::Plugin.load(:"#{slug}")
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

  # TODO: 同じ処理をうまいこと統合する
  command(:plugin_reloader_detach,
          name:      'プラグインを外す',
          condition: ->(_) { true },
          visible:   true,
          role:      :postbox) do |opt|
    # postboxからメッセージを取得
    slug = Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text
    if slug.nil? || slug.empty? || slug == 'plugin_reloader'
      error 'slug is not acceptable'
      next
    end
    detach(slug)
    Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text = ''
  end

  command(:plugin_reloader_attach,
          name:      'プラグインをロードする',
          condition: ->(_) { true },
          visible:   true,
          role:      :postbox) do |opt|
    # postboxからメッセージを取得
    slug = Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text
    if slug.nil? || slug.empty? || slug == 'plugin_reloader'
      error 'slug is not acceptable'
      next
    end
    attach(slug)
    Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text = ''
  end

  command(:plugin_reloader_reload,
          name:      'プラグインをリロードする',
          condition: ->(_) { true },
          visible:   true,
          role:      :postbox) do |opt|
    # postboxからメッセージを取得
    slug = Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text
    if slug.nil? || slug.empty? || slug == 'plugin_reloader'
      error 'slug is not acceptable'
      next
    end
    detach(slug)
    attach(slug)
    Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text = ''
  end
end
