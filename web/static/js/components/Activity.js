import React from 'react';
import YouTube from 'react-youtube';
import styles from './Activity.scss';

const pluralize = (number, singular) =>
  `${number} ${singular}${number != 1 ? 's' : ''}`;

const activityPresenter = (activity) => {
  switch(activity.type) {
    case "points_scored":
      return {
        message: `${activity.user.username} scored ${pluralize(activity.points, 'point')}`,
        videoUrl: activity.video.url
      };
      break;

    default:
      console.error('No presenter for activity type', activity.type);
  }
};

export default class Activity extends React.Component {
  render() {
    const { message, videoUrl } = activityPresenter(this.props.activity);
    const opts = {
      height: 360,
      width: 640,
      // https://developers.google.com/youtube/player_parameters
      playerVars: { autoplay: 1, controls: 0, modestbranding: 1, playsinline: 1,
        showinfo: 0 } };

    return (
      <div className={styles.container}>
        <div className={styles.message}>
          {message}
        </div>
        <div className={styles.video}>
          <YouTube url={videoUrl} opts={opts} />
        </div>
      </div>
    );
  }
}