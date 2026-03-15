import React from 'react'

export function AuthorCard() {
  return (
    <div className="border border-gray-200 dark:border-gray-800 rounded-lg p-6 my-8 bg-gradient-to-r from-blue-50 to-purple-50 dark:from-blue-900/20 dark:to-purple-900/20">
      <div className="flex flex-col md:flex-row gap-6 items-center">
        <div className="flex-shrink-0">
          <div className="w-24 h-24 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center text-white text-3xl font-bold shadow-lg">
            BD
          </div>
        </div>
        <div className="flex-1 text-center md:text-left">
          <h3 className="text-2xl font-bold mb-2">Bouna DRAME</h3>
          <p className="text-lg text-gray-600 dark:text-gray-400 mb-3">
            🚀 Full-Stack Developer | Open Source Contributor | CSPro & Statistical Systems Expert
          </p>
          <p className="text-gray-700 dark:text-gray-300 mb-4">
            Passionné par la démocratisation des outils statistiques en Afrique. Spécialisé en architecture de systèmes de collecte de données (CSPro, CSWeb) et développement d'applications modernes (Spring Boot, React, Next.js).
          </p>
          <div className="flex flex-wrap gap-3 justify-center md:justify-start">
            <a
              href="https://bounadrame.github.io/portfolio/"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium shadow-md hover:shadow-lg"
            >
              🌐 Portfolio
            </a>
            <a
              href="https://github.com/BOUNADRAME"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 px-4 py-2 bg-gray-800 text-white rounded-lg hover:bg-gray-900 transition-colors font-medium shadow-md hover:shadow-lg"
            >
              💼 GitHub
            </a>
            <a
              href="https://www.linkedin.com/in/bouna-drame"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 px-4 py-2 bg-blue-700 text-white rounded-lg hover:bg-blue-800 transition-colors font-medium shadow-md hover:shadow-lg"
            >
              🔗 LinkedIn
            </a>
          </div>
        </div>
      </div>
    </div>
  )
}

interface ProjectCardProps {
  title: string
  description: string
  icon?: string
}

export function ProjectCard({ title, description, icon = '🚀' }: ProjectCardProps) {
  return (
    <div className="border border-gray-200 dark:border-gray-800 rounded-lg p-4 hover:shadow-lg transition-shadow">
      <h4 className="font-bold mb-2">
        {icon} {title}
      </h4>
      <p className="text-sm text-gray-600 dark:text-gray-400">
        {description}
      </p>
    </div>
  )
}

export function ContactCTA() {
  return (
    <div className="border-2 border-blue-500 dark:border-blue-600 rounded-lg p-6 my-8 bg-blue-50 dark:bg-blue-900/20">
      <h3 className="text-xl font-bold mb-3">💼 Besoin d'un Développeur Full-Stack ?</h3>

      <p className="mb-4 text-gray-700 dark:text-gray-300">
        Vous cherchez un développeur expérimenté pour :
      </p>

      <ul className="space-y-2 mb-4 text-gray-700 dark:text-gray-300">
        <li>🏗️ Architecture de systèmes statistiques (CSPro, ODK, KoboToolbox)</li>
        <li>🔧 Développement backend (Spring Boot, Node.js, API REST)</li>
        <li>⚛️ Applications frontend modernes (React, Next.js, TypeScript)</li>
        <li>🐳 DevOps & Infrastructure (Docker, CI/CD, PostgreSQL, MongoDB)</li>
        <li>📊 Analytics & BI (Power BI, Metabase, Tableau)</li>
      </ul>

      <div className="flex flex-wrap gap-3">
        <a
          href="https://bounadrame.github.io/portfolio/"
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center gap-2 px-5 py-2.5 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors font-medium shadow-md hover:shadow-lg"
        >
          🌐 Voir mon Portfolio
        </a>
        <a
          href="https://www.linkedin.com/in/bouna-drame"
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center gap-2 px-5 py-2.5 bg-white dark:bg-gray-800 border-2 border-blue-600 text-blue-600 dark:text-blue-400 rounded-lg hover:bg-blue-50 dark:hover:bg-gray-700 transition-colors font-medium"
        >
          💬 Me Contacter
        </a>
      </div>
    </div>
  )
}
