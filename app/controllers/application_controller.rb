require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "password_security"
  end

  get '/' do
    erb :index
  end

  get '/signup' do
    if logged_in?
      redirect "/tweets"
    else
      erb :'/users/create_user'
    end
  end

  post '/signup' do
    user = User.new(params)
		if user.save && user.authenticate(params[:password])
      session[:id] = user.id
			redirect "/tweets"
    else
			redirect "/signup"
		end
  end

  get '/tweets' do
    if logged_in?
      erb :'/tweets/tweets'
    else
      redirect '/login'
    end
  end

  get '/login' do
    if logged_in?
      redirect "/tweets"
    else
      erb :'/users/login'
    end
  end

  post '/login' do
    user = User.find_by(username: params[:username])
		if user && user.authenticate(params[:password])
			session[:id] = user.id
			redirect "/tweets"
		else
			redirect "/"
		end
  end

  get '/users/:slug' do
    @user = User.find_by_slug(params[:slug])
    erb :'/tweets/tweets'
  end

  get "/logout" do
    session.clear
    redirect "/login"
  end

  get '/tweets/new' do
    if logged_in?
      erb :'/tweets/create_tweet'
    else
      redirect "/login"
    end
  end

  post '/tweets/new' do
    tweet = Tweet.create(params)
    if tweet.content.empty?
      redirect '/tweets/new'
    else
      current_user.tweets << tweet
      redirect "/tweets/#{tweet.id}"
    end
  end

  get '/tweets/:id' do
    if logged_in?
      @tweet = Tweet.find(params[:id])
      erb :'/tweets/show_tweet'
    else
      redirect "/login"
    end
  end

  get '/tweets/:id/edit' do
    if logged_in?
      @tweet = Tweet.find(params[:id])
      if @tweet.user_id == session[:id]
        erb :'/tweets/edit_tweet'
      end
    else
      redirect "/login"
    end
  end

  delete '/tweets/:id/delete' do
    @tweet = Tweet.find(params[:id])
    if logged_in? && @tweet.user_id == session[:id]
      @tweet.destroy
      redirect '/tweets'
    else
      redirect "/login"
    end
  end

  patch '/tweets/:id/edit' do
    tweet = Tweet.find(params[:id])
    if params["content"].empty?
      redirect "/tweets/#{tweet.id}/edit"
    else
      tweet.update(content: params["content"])
      redirect '/tweets'
    end
  end

  helpers do
    def logged_in?
      !!session[:id]
    end

    def current_user
      User.find(session[:id])
    end
  end

end
