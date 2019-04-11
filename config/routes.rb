Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'user#log' 

  get '/'                                  => 'user#log'
  get '/user/index'                        => 'user#index'
  get '/user/authenticate'                 => 'user#authentication'
  get '/patient/confirm'                   => 'patient#confirm'
  get '/order/requested_orders'            => 'order#requested_orders'
  get '/order/check'                       => 'order#check'
  get '/order/update_order_status'         => 'order#update_order_status'
  get '/order/print_tracking_number'       => 'order#print_tracking_number'
  get '/order/test_types'                  => 'order#select_test_types'
  get '/order/order_test'                  => 'order#order_test'
  get '/order/get_target_labs'             => 'order#get_target_labs'
  get '/order/get_order_location'          => 'order#get_order_location'
  post '/order/save_order'                 => 'order#save_order'
  get '/order/confirm_order'               => 'order#confirm_order'
  post '/order/update_order_confirmation'  => 'order#update_order_confirmation' 
  get  '/order/enter_result'               => 'order#result_entrly'
  post '/patient/select'                   => 'patient#select'
  get  '/patient/select'                   => 'patient#select'
  get '/patient/search_patient'            => 'patient#search_patient'
  post '/patient/search_patient'           => 'patient#search_patient'
  get '/order/enter_result_value'          => 'order#enter_result_value'
  get '/order/save_results'                => 'order#save_result'
  get '/patient/search_by_name'            => 'patient#search_by_name'
  get '/patient/search_by_name_results'    => 'patient#search_by_name_results'
  post '/patient/set_patient_in_session'   => 'patient#set_patient_in_session'
  get '/patient/set_patient_in_session'    => 'patient#set_patient_in_session'
  post '/order/test_result_entry_confirmation'                 => 'order#test_result_entry_confirmation'
  get '/order/test_result_entry_confirmation'                  => 'order#test_result_entry_confirmation'
  get '/order/edit_result'                 => 'order#edit_result'
  post '/order/save_edited_result'         => 'order#save_edited_result'
  get '/patient/search_by_arv_number'      => 'patient#search_by_arv_number'


end
