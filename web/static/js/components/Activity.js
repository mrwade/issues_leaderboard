import React from 'react';
import YouTube from 'react-youtube';
import styles from './Activity.scss';

export default class Activity extends React.Component {
  render() {
    const { message, video } = this.props.activity;
    const opts = {
      height: window.innerHeight - 100,
      width: window.innerWidth,
      // https://developers.google.com/youtube/player_parameters
      playerVars: { autoplay: 1, controls: 0, modestbranding: 1, playsinline: 1,
        showinfo: 0 } };

    return (
      <div className={styles.container}>
        <div className={styles.video}>
          <YouTube url={video} opts={opts} onEnd={this.props.onVideoEnd} />
        </div>
        <div className={styles.message}>{message}</div>
      </div>
    );
  }
}
