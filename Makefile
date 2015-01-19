all: keys

keys:
	bundle exec pod keys set ArtsyFacebookTwitterSecret
	bundle exec pod keys set ArtsyFacebookTwitterKey
	bundle exec pod keys set ArtsyFacebookStagingToken
	bundle exec pod keys set ArtsyFacebookAppID
	bundle exec pod keys set ArtsyAPIClientKey
	bundle exec pod keys set ArtsyAPIClientSecret
