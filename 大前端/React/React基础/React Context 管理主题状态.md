# React Context 管理主题状态

## 一、定义 context、provider

context -> theme.context.tsx

```tsx
import React, { createContext, FC, ReactNode } from 'react';

type ThemeContextType = 'light' | 'dark';

const ThemeContext = createContext<ThemeContextType>('dark');

interface ThemeProviderProps {
	children: ReactNode | ReactNode[];
}

const ThemeProvider: FC<ThemeProviderProps> = ({ children}) => {
	const initialTheme: ThemeContextType = 'light'; // 初始主题

	return (
		<ThemeContext.Provider value={initialTheme}>
			{ children }
		</ThemeContext.Provider>
	);
}

export {
	ThemeContext,
	ThemeProvider
}

export type {
	ThemeContextType,
	ThemeProviderProps,
}
```

### 二、定义 useTheme Hook 对Context进行消费

hooks -> useTheme.tsx

``` tsx
import { ThemeContext } from '../context/theme.context';
import { useContext } from 'react';

const useTheme = () => {
	const theme = useContext(ThemeContext);
	if (theme === undefined) {
		throw new Error('useTheme must be used within a ThemeProvider');
	}

	return theme;
}


export default useTheme;
```

### 三、在顶层组件中包裹 Theme Context 

```tsx
// App.tsx
function App() {
	return (
		<>
			<ThemeProvider>
				<Title />
			</ThemeProvider>
		</>
	)
}

export default App;

//  Title.tsx
import React from 'react';
import useTheme from './hooks/useTheme';

const Title: React.FC = () => {
	const theme = useTheme()
	return <div> { theme } {/* light */} </div>
}

export default Title;
```

