import { Socket } from '../../../../deps/phoenix/web/static/js/phoenix';
import React from 'react';
import Activity from './Activity';
import styles from './App.scss';

export default class App extends React.Component {
  componentWillMount() {
    let socket = new Socket('/socket');
    socket.connect();

    let channel = socket.channel("boards:default", {});
    channel.join()
      .receive("ok", resp => { console.log("Socket opened", resp) })
      .receive("error", resp => { console.log("Unable to open socket", resp) });

    channel.on('update', (board) => {
      console.log('Board update', board);
      const { rankings, activities } = board;
      this.setState({ rankings, activity: activities[0] });
    });
  }

  render() {
    if (!this.state)
      return <div>Loading...</div>;

    return (
      <div>
        <div>
          {this.state.rankings.map(ranking =>
            <div key={ranking.user.username} className={styles.ranking}>
              <div className={styles.rank}>
                {ranking.rank}
              </div>
              <div className={styles.avatar}>
                <img src={ranking.user.avatar_url} />
              </div>
              <div className={styles.points}>
                {ranking.issues.map(issue =>
                  <div key={issue.number}
                    className={[styles.issue, styles[`pointValue${issue.points}`]].join(' ')}>
                    {issue.points}
                  </div>
                )}
              </div>
            </div>
          )}
        </div>
        {this.renderActivity()}
      </div>
    );
  }

  renderActivity() {
    if (this.state.activity) {
      return <Activity activity={this.state.activity} />;
    }
  }
}
