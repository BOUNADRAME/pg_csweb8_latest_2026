import React, { useState } from 'react'

interface TabsProps {
  items: string[]
  children: React.ReactNode[]
}

export function Tabs({ items, children }: TabsProps) {
  const [activeIndex, setActiveIndex] = useState(0)

  return (
    <div className="my-6 border border-gray-200 dark:border-gray-800 rounded-lg overflow-hidden">
      <div className="flex border-b border-gray-200 dark:border-gray-800 bg-gray-50 dark:bg-gray-900">
        {items.map((item, index) => (
          <button
            key={index}
            onClick={() => setActiveIndex(index)}
            className={`px-4 py-2 text-sm font-medium transition-colors ${
              activeIndex === index
                ? 'bg-white dark:bg-gray-800 text-blue-600 dark:text-blue-400 border-b-2 border-blue-600 dark:border-blue-400'
                : 'text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-200'
            }`}
          >
            {item}
          </button>
        ))}
      </div>
      <div className="p-4 bg-white dark:bg-gray-800">
        {Array.isArray(children) ? children[activeIndex] : children}
      </div>
    </div>
  )
}
