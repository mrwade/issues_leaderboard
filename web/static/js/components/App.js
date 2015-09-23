import { Socket } from '../../../../deps/phoenix/web/static/js/phoenix';
import React from 'react';
import ActivityPlayer from './ActivityPlayer';
import styles from './App.scss';

const pluralize = (number, singular) =>
  `${number} ${singular}${number != 1 ? 's' : ''}`;

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
      this.setState({ rankings, activities });
    });
  }

  render() {
    if (!this.state)
      return <div>Loading...</div>;

    return (
      <div>
        <div className={styles.title}>Bug Shootout</div>
        <div className={styles.rankings}>
          {this.state.rankings.map(ranking =>
            <div key={ranking.user.username} className={styles.ranking}>
              <div className={styles.rank}>
                {ranking.rank}
              </div>
              <div className={styles.avatar}>
                <img src={ranking.user.avatar_url} />
              </div>
              <div className={styles.username}>
                {ranking.user.username}
              </div>
              <div className={styles.issues}>
                {ranking.issues.map(issue =>
                  <div key={issue.number}
                    className={[styles.issue, styles[`pointValue${issue.points}`]].join(' ')}>
                    {issue.points}
                  </div>
                )}
              </div>
              <div className={styles.total}>
                {pluralize(ranking.total, 'point')}
              </div>
            </div>
          )}
        </div>
        <ActivityPlayer activities={this.state.activities} />
      </div>
    );
  }
}
