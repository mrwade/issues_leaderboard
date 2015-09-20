import { Socket } from '../../../../deps/phoenix/web/static/js/phoenix';
import React from 'react';
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
      const { rankings } = board;
      this.setState({ rankings });
    });
  }

  render() {
    if (!this.state)
      return <div>Loading...</div>;

    return (
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
    );
  }
}
