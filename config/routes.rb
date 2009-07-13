ActionController::Routing::Routes.draw do |map|
  map.connect 'cart/:action/:id', :controller => 'cart'
  map.connect 'browse/*slugs', :controller => 'cart', :action => 'tag'
  map.connect 'customer/:action/:id', :controller=>'customer'

  map.connect 'office', :controller => 'office/gateway', :action => 'index'

  map.namespace :office do |office|

    office.resources(
      :products,
      :member => {
        :available => :post,
        :featured => :post,
        :duplicate => :get,
        :tag => :post,
        :remove_image => :post,
        :update_matrix => :post
      },
      :has_many => [
        :product_images,
        :tag_activations,
        :tags,
        :tag_sets,
        :option_sets
      ]
    )

    office.resources(
      :product_images,
      :member => {
        :reorder => :post
      }
    )

    office.resources(
      :option_sets,
      :has_many => [
        :options
      ]
    )

    office.resources :tag_activations

    office.resources(
      :tag_sets,
      :has_many => [
        :tags
      ]
    )

    office.resources :tags

    office.resources :options

    office.resources :variations

    office.resources :cart_configs

    office.resources :customers

    office.resources :error_messages

    office.resources :coupons

    office.resources :carts

  end
#  map.connect 'browse/*slugs', :controller=>'cart', :action=>'tag'
#  map.connect 'product/:slug', :controller=>'cart', :action=>'product'
end
