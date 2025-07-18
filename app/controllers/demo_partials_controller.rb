class DemoPartialsController < ApplicationController
  def new
    @zone = t("demo_partials.zone_new")
    @date = Time.zone.today
  end

  def edit
    @zone = t("demo_partials.zone_edit")
    @date = Time.zone.today - 4
  end
end
