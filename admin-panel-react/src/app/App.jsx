import { Routes, Route, Navigate } from 'react-router-dom'
import AdminLayout from '../layouts/AdminLayout.jsx'
import LoginPage from '../pages/LoginPage.jsx'
import DashboardPage from '../pages/DashboardPage.jsx'
import UsersPage from '../pages/UsersPage.jsx'
import BusinessesPage from '../pages/BusinessesPage.jsx'
import CandidatesPage from '../pages/CandidatesPage.jsx'
import JobsPage from '../pages/JobsPage.jsx'
import ApplicationsPage from '../pages/ApplicationsPage.jsx'
import InterviewsPage from '../pages/InterviewsPage.jsx'
import MessagesPage from '../pages/MessagesPage.jsx'
import NotificationsPage from '../pages/NotificationsPage.jsx'
import ReportsPage from '../pages/ReportsPage.jsx'
import SubscriptionsPage from '../pages/SubscriptionsPage.jsx'
import CommunityPage from '../pages/CommunityPage.jsx'
import FeaturedPage from '../pages/FeaturedPage.jsx'
import MatchesPage from '../pages/MatchesPage.jsx'
import LogsPage from '../pages/LogsPage.jsx'
import SettingsPage from '../pages/SettingsPage.jsx'

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route element={<AdminLayout />}>
        <Route path="/" element={<Navigate to="/dashboard" replace />} />
        <Route path="/dashboard" element={<DashboardPage />} />
        <Route path="/users" element={<UsersPage />} />
        <Route path="/businesses" element={<BusinessesPage />} />
        <Route path="/candidates" element={<CandidatesPage />} />
        <Route path="/jobs" element={<JobsPage />} />
        <Route path="/applications" element={<ApplicationsPage />} />
        <Route path="/interviews" element={<InterviewsPage />} />
        <Route path="/messages" element={<MessagesPage />} />
        <Route path="/notifications" element={<NotificationsPage />} />
        <Route path="/reports" element={<ReportsPage />} />
        <Route path="/subscriptions" element={<SubscriptionsPage />} />
        <Route path="/community" element={<CommunityPage />} />
        <Route path="/featured" element={<FeaturedPage />} />
        <Route path="/matches" element={<MatchesPage />} />
        <Route path="/logs" element={<LogsPage />} />
        <Route path="/settings" element={<SettingsPage />} />
      </Route>
    </Routes>
  )
}
