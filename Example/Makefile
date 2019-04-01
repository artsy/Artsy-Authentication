all: install

install:
	pod repo update
	pod install

keys:
	bundle exec pod keys set ArtsyTwitterSecret "" Artsy_Authentication
	bundle exec pod keys set ArtsyTwitterKey ""
	bundle exec pod keys set ArtsyFacebookAppID ""
	bundle exec pod keys set ArtsyAPIClientKey ""
	bundle exec pod keys set ArtsyAPIClientSecret ""
