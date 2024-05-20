import {FC, memo, useCallback, useEffect, useState} from "react";

/**
 * Writing the User type in a separate file can enhance the extensibility of the component.
 */
interface User {
	name: string;
	email: string;
	[key: string]: unknown;
}

interface Props {
	userId: string
}

/**
 * @param userId
 * @constructor
 */
const FunctionalBased: FC<Props> = (
	{
		userId
	}
) => {
	const [seconds, setSeconds] = useState<number>(0);
	const [user, setUser] = useState<User | null>(null);

	/**
	 * The fetchUserData method can be converted into a pure function.
	 * The entire request logic can be wrapped into a hook that includes data, error, loading, and caching state.
	 */
	const fetchUserData = useCallback((userId: string) => {
		fetch(`https://secret.url/user/${userId}`)
			.then(response => response.json())
			.then(data => setUser(data))
			.catch(error => console.error('Error fetching user data:', error));
	}, [])

	useEffect(() => {
		fetchUserData(userId)
	}, [userId]);

	useEffect(() => {
		const intervalId = setInterval(() => {
			setSeconds(prevState => prevState + 1);
		}, 1000);

		return () => clearInterval(intervalId);
	}, []);

	return <div>
		<h1>User Data Component</h1>
		{user ? (
			<div>
				<p>Name: {user.name}</p>
				<p>Email: {user.email}</p>
			</div>
		) : (
			<p>Loading user data...</p>
		)}
		<p>Timer: {seconds} seconds</p>
	</div>
}

export default memo(FunctionalBased);

export type {
	Props as FunctionalBasedProps
}