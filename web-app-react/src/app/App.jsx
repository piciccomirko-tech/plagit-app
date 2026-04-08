import { Routes, Route } from 'react-router-dom'
import MainLayout from '../layouts/MainLayout.jsx'
import HomePage from '../pages/HomePage.jsx'
import JobsPage from '../pages/JobsPage.jsx'
import LoginPage from '../pages/LoginPage.jsx'
import NotFoundPage from '../pages/NotFoundPage.jsx'

export default function App() {
  return (
    <Routes>
      <Route element={<MainLayout />}>
        <Route path="/" element={<HomePage />} />
        <Route path="/jobs" element={<JobsPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="*" element={<NotFoundPage />} />
      </Route>
    </Routes>
  )
}
