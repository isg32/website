export function formatDate(date: Date | string | null): string {
	if (!date) return '--';
	const d = typeof date === 'string' ? new Date(date) : date;
	return d
		.toLocaleDateString('en-US', {
			month: 'short',
			day: '2-digit',
			year: 'numeric'
		})
		.toUpperCase();
}
