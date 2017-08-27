Rails.application.routes.draw do
  post '/user/create_skills_data', to: 'users#create_skill_sets'
  root to: 'users#get_questions'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
