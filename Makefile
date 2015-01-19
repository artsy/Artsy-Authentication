all: keys

keys:
	cd Example
	bundle exec pod keys set ArtsyFacebookTwitterSecret "" Artsy_Authentication
	bundle exec pod keys set ArtsyFacebookTwitterKey ""
	bundle exec pod keys set ArtsyFacebookStagingToken ""
	bundle exec pod keys set ArtsyFacebookAppID ""
	bundle exec pod keys set ArtsyAPIClientKey ""
	bundle exec pod keys set ArtsyAPIClientSecret ""
	cd ..
