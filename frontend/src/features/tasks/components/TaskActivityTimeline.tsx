import type { Activity } from '../types'

type TaskActivityTimelineProps = {
  activities: Activity[]
}

export function TaskActivityTimeline({ activities }: TaskActivityTimelineProps) {
  if (!activities.length) {
    return <p className="no-activities">No recent activity</p>
  }

  return (
    <ul className="activity-timeline">
      {activities.map((activity) => (
        <li key={activity.id}>
          <span className="activity-time">
            {new Date(activity.createdAt).toLocaleString()}
          </span>
          <span className="activity-action">{activity.action}</span>
        </li>
      ))}
    </ul>
  )
}

