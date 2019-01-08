Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'user#log' 

  get '/'                              => 'user#log'
  get '/user/index'                    => 'user#index'
  get '/user/authenticate'             => 'user#authentication'
  get '/patient/confirm'               => 'patient#confirm'
  get '/order/requested_orders'        => 'order#requested_orders'
  get '/order/update_order_status'     => 'order#update_order_status'
  get '/order/print_tracking_number'   => 'order#print_tracking_number'
  get '/order/test_types'              => 'order#select_test_types'
  get '/order/order_test'              => 'order#order_test'
  get '/order/get_target_labs'         => 'order#get_target_labs'
  get '/order/get_order_location'      => 'order#get_order_location'
  post '/order/save_order'             => 'order#save_order'
  get '/order/confirm_order'           => 'order#confirm_order'
  post '/order/update_order_confirmation'    => 'order#update_order_confirmation' 

end
