import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { ApolloProvider } from '@apollo/client/react'
import { Provider } from 'react-redux'
import './index.css'
import App from './App.tsx'
import { store } from './app/store.ts'
import { apolloClient } from './lib/apolloClient.ts'
import { ThemeProvider } from './theme'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <Provider store={store}>
      <ThemeProvider>
        <ApolloProvider client={apolloClient}>
          <App />
        </ApolloProvider>
      </ThemeProvider>
    </Provider>
  </StrictMode>,
)
