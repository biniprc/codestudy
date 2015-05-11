require 'sinatra'
require 'data_mapper'
enable :sessions

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/hotel.db")

class User
  include DataMapper::Resource
  property :id, Serial
  property :user_email, String #문자열
  property :user_password, String #긴 문자열
  property :created_at, DateTime
	property :admin, Boolean #property :user_level, Integer형식으로 만들 수도 있음 
end

DataMapper.finalize #데이터 베이스 끝
User.auto_upgrade! #데이터베이스 자동 업그레이드 (추가시)

get '/' do
	@c_set = ["서울", "뉴욕", "파리", "판교", "케이프타운"]
	@email_name = session[:email]
  erb :index
end

get '/login' do
	@c_set = ["서울", "뉴욕", "파리", "판교", "케이프타운"]
	erb :login
end

post '/login_process' do	
	database_user = User.first(:user_email => params[:user_email])

	md5_user_password = Digest::MD5.hexdigest(params[:user_password]) #인자로 넘어온 것을 암호화
	if !database_user.nil?
		if database_user.user_password == md5_user_password
			session[:email] = params[:user_email]
		end
	end	

	redirect '/'
end

get '/logout' do
	session.clear
	redirect '/'
end

get '/join' do
	@c_set = ["서울", "뉴욕", "파리", "판교", "케이프타운"]
	erb :join
end

post '/join_process' do
	n_user = User.new
	
	n_user.user_email = params[:user_email] #database의 이름은 같아야 함//인자는 같을 필요없음
	md5_password = Digest::MD5.hexdigest(params[:user_password])
	n_user.user_password = md5_password
	n_user.admin = false
	n_user.save
	
	redirect '/'
end

# before filter -> admin page 하나로 묶기
get '/admin' do
	user = User.first(:user_email => session[:email])
	if (!user.nil?) and (user.admin == true)
		@users = User.all
		erb :admin
	else
		redirect '/'
	end
end

get '/user_delete/:user_id' do
	user = User.first(:user_email => session[:email])
	if (!user.nil?) and (user.admin == true)
		user = User.first(:id  => params[:user_id])
		user.destory
		redirect '/admin'
	else
		redirect '/'
	end
end

get '/init_database' do #QQQQQQQQQQQQQQQQQ 실제로 서비스 오픈할 땐 반드시 빼야함
	n_user = User.new
	n_user.user_email = "admin@admin.com"  #database의 이름은 같아야 함//인자는 같을 필요없음
	md5_password = Digest::MD5.hexdigest("asdf")
	n_user.user_password = md5_password
	n_user.admin = true
	n_user.save
	
	redirect '/'
end

get '/destroy_database' do #QQQQQQQQQQQQQQQ
	User.all.destroy
	redirect '/'
end
