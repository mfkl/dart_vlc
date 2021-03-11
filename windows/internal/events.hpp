#include "setters.hpp"


class AudioPlayerEvents : public AudioPlayerSetters {
public:
	void onLoad(std::function<void(VLC::Media)> callback) {
		this->_loadCallback = callback;
		this->mediaPlayer.eventManager().onMediaChanged(
			std::bind(&AudioPlayerEvents::_onLoadCallback, this, std::placeholders::_1)
		);
	}

	void onPlay(std::function<void(void)> callback) {
		this->_playCallback = callback;
		this->mediaPlayer.eventManager().onPlaying(
			std::bind(&AudioPlayerEvents::_onPlayCallback, this)
		);
	}

	void onPause(std::function<void(void)> callback) {
		this->_pauseCallback = callback;
		this->mediaPlayer.eventManager().onPaused(
			std::bind(&AudioPlayerEvents::_onPauseCallback, this)
		);
	}

	void onStop(std::function<void(void)> callback) {
		this->_stopCallback = callback;
		this->mediaPlayer.eventManager().onStopped(
			std::bind(&AudioPlayerEvents::_onStopCallback, this)
		);
	}

	void onPosition(std::function<void(int)> callback) {
		this->_positionCallback = callback;
		this->mediaPlayer.eventManager().onPositionChanged(
			std::bind(&AudioPlayerEvents::_onPositionCallback, this, std::placeholders::_1)
		);
	}

	void onVolume(std::function<void(float)> callback) {
		this->_volumeCallback = callback;
		this->mediaPlayer.eventManager().onAudioVolume(
			std::bind(&AudioPlayerEvents::_onVolumeCallback, this, std::placeholders::_1)
		);
	}

	void onComplete(std::function<void(void)> callback) {
		this->_completeCallback = callback;
		this->mediaPlayer.eventManager().onEndReached(
			std::bind(&AudioPlayerEvents::_onCompleteCallback, this)
		);
	}

	void onNext(std::function<void(void)> callback) {
		this->_nextCallback = callback;
		this->mediaListPlayer.eventManager().onNextItemSet(
			std::bind(&AudioPlayerEvents::_onNextCallback, this)
		);
	}

private:
	void _updateAudioPlayerState(bool isCompleted = false) {
		this->state->isPlaying = this->mediaPlayer.isPlaying();
		this->state->isValid = this->mediaPlayer.isValid();
		this->state->isCompleted = isCompleted;
		this->state->position = this->getPosition();
		this->state->duration = this->getDuration();
	}

	std::function<void(VLC::Media)> _loadCallback;

	void _onLoadCallback(VLC::MediaPtr media) {
		if (this->getDuration() > 0) {
			this->_updateAudioPlayerState();
			this->_loadCallback(*media.get());
		}
		else {
			this->state->index = this->mediaList.indexOfItem(*media.get());
		}
	};

	std::function<void(void)> _playCallback;

	void _onPlayCallback() {
		if (this->getDuration() > 0) {
			this->_updateAudioPlayerState();
			this->_playCallback();
		}
	};

	std::function<void(void)> _pauseCallback;

	void _onPauseCallback() {
		if (this->getDuration() > 0) {
			this->_updateAudioPlayerState();
			this->_pauseCallback();
		}
	};

	std::function<void(void)> _stopCallback;

	void _onStopCallback() {
		if (this->getDuration() > 0) {
			this->_updateAudioPlayerState();
			this->_stopCallback();
		}
	};

	std::function<void(int)> _positionCallback;

	void _onPositionCallback(float relativePosition) {
		if (this->getDuration() > 0) {
			this->_updateAudioPlayerState();
			this->_positionCallback(
				static_cast<int>(relativePosition * this->mediaPlayer.length())
			);
		}
	};

	std::function<void(double)> _volumeCallback;

	void _onVolumeCallback(int volume) {
		if (this->getDuration() > 0) {
			this->state->volume = static_cast<double>(volume) / 100.0f;
			this->_volumeCallback(this->state->volume);
		}
	};

	std::function<void(void)> _completeCallback;

	void _onCompleteCallback() {
		if (this->getDuration() > 0) {
			this->_updateAudioPlayerState(true);
			this->_completeCallback();
		}
	};

	std::function<void(void)> _nextCallback;

	void _onNextCallback() {
		if (this->getDuration() > 0) {
			this->_updateAudioPlayerState();
			this->_nextCallback();
		}
	};
};
