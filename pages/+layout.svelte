<script>
	import '@evidence-dev/tailwind/fonts.css';
	import '../app.css';
	import { EvidenceDefaultLayout } from '@evidence-dev/core-components';
	import { base } from '$app/paths';
	export let data;
	const logoPath = `${base}/mle_banner_logo.png`;
</script>

<EvidenceDefaultLayout {data} logo={logoPath} githubRepo="https://github.com/Minor-League-Esports/evidence" xProfile="https://twitter.com/MLEsportsGG" fullWidth={true}>
	<slot slot="content" />
</EvidenceDefaultLayout>
