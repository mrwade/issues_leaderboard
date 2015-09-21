import Notify from 'notifyjs';
import React from 'react';
import _ from 'underscore';
import Activity from './Activity';
import styles from './ActivityPlayer.scss';

export default class ActivityPlayer extends React.Component {
  constructor(props) {
    super(props);
    this.state = { activities: props.activities || [] };
  }

  componentDidMount() {
    this.playNextActivity();
  }

  componentWillReceiveProps(nextProps) {
    this.setState({
      activities: this.state.activities.concat(nextProps.activities)
    });
    // FIXME
    _.defer(() => this.playNextActivity());
  }

  render() {
    if (this.state.activity) {
      return (
        <Activity activity={this.state.activity}
          onVideoEnd={() => this.onVideoEnd()} />
      );
    } else {
      return <div />;
    }
  }

  playNextActivity() {
    if (!this.state.activity && this.state.activities.length) {
      const nextActivity = this.state.activities[0];
      if (nextActivity)
        this.displayNotification(nextActivity);

      this.setState({
        activity: nextActivity,
        activities: _.rest(this.state.activities)
      });
    }
  }

  displayNotification(activity) {
    let notify = () => {
      (new Notify('Bug Shootout', {
        body: activity.message,
        timeout: 7
      })).show();
    };

    if (Notify.needsPermission) {
      Notify.requestPermission(notify);
    } else {
      notify();
    }
  }

  onVideoEnd() {
    if (this.state.activities.length) {
      this.playNextActivity();
    } else {
      this.setState({ activity: undefined });
    }
  }
}
