// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import { initAll } from "govuk-frontend"

document.addEventListener("turbo:load", () => initAll())
