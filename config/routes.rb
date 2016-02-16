Rails.application.routes.draw do
  resources :cages, except: [:new, :edit]
  resources :dinosaurs, except: [:new, :edit] do
    collection do
      #add a dinosaurs/cage route to put dinosaurs in a cage
      put 'to_cage' => 'dinosaurs#to_cage'
    end
  end

end
