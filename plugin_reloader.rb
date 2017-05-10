# -*- coding: utf-8 -*-
# -*- frozen_string_literal: true -*-

Plugin.create(:plugin_reloader) do
  # アクティビティ設定
  defactivity 'plugin_reloader_status', 'プラグインリロード'

  def check_slug(slug)
    case slug
    when ''
      activity :plugin_reloader_status, 'プラグインのスラグがありません'
      false
    when 'plugin_reloader'
      activity :plugin_reloader_status, 'リロードできないプラグインです'
      false
    else
      true
    end
  end

  def detach(opt)
    # postboxからメッセージを取得
    plugin_slug = Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text
    return unless check_slug(plugin_slug)
    # スラグの生成
    plugin_slug = plugin_slug.slice(/^:/) if plugin_slug[0] == ':'
    Plugin.uninstall(:"#{plugin_slug}")
    Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text = ''
    activity :plugin_reloader_status, "プラグイン #{plugin_slug} のアンインストールを完了しました"
  end

  def attach(opt)
    # postboxからメッセージを取得
    plugin_slug = Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text
    return unless check_slug(plugin_slug)
    # スラグの生成
    plugin_slug = plugin_slug.slice(/^:/) if plugin_slug[0] == ':'
    Miquire::Plugin.load(:"#{plugin_slug}")
    Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text = ''
    activity :plugin_reloader_status, "プラグイン #{plugin_slug} のロードを完了しました"
  end

  command(:plugin_reloader_detach,
          name:      'プラグインを外す',
          condition: ->(_) { true },
          visible:   true,
          role:      :postbox) do |opt|
    detach(opt)
  end

  command(:plugin_reloader_attach,
          name:      'プラグインをロードする',
          condition: ->(_) { true },
          visible:   true,
          role:      :postbox) do |opt|
    attach(opt)
  end

  command(:plugin_reloader_reload,
          name:      'プラグインをリロードする',
          condition: ->(_) { true },
          visible:   true,
          role:      :postbox) do |opt|
    detach(opt)
    attach(opt)
  end
end
