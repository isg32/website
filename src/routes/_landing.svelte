<script lang="ts">
	import { mdiGithub, mdiOpenInNew, mdiLinkedin, mdiMessage } from "@mdi/js"
	import Icon from "$components/Icon.svelte"
	import Logo from "$components/Logo.svelte"
</script>

<section class="landing">
	<h1>
		Hi, I'm <br /> Sapan Gajjar
		<Logo size="0.9em" color="var(--color-primary-400)" />
	</h1>
	<p>I'm a Developer based in Ahmedabad.</p>
	<p>
		I care about low-level systems, full-stack web/mobile development, DevOps,
		and problem-solving.
	</p>
	<hr class="bold" />
	<ul class="links">
		<li>
			<a
				href="https://www.linkedin.com/in/sapangajjar101105/"
				title="LinkedIn profile"
				target="_blank"
				rel="noopener"
			>
				<Icon title="LinkedIn Icon" path={mdiLinkedin} size="1.5em" />
				<span>LinkedIn</span>
				<Icon path={mdiOpenInNew} />
			</a>
		</li>
		<li>
			<a
				href="https://github.com/SapanGajjar"
				title="GitHub profile"
				target="_blank"
				rel="noopener"
			>
				<Icon title="GitHub Icon" path={mdiGithub} size="1.5em" />
				<span>GitHub</span>
				<Icon path={mdiOpenInNew} />
			</a>
		</li>
		<li>
			<a
				href="https://t.me/semisapeol"
				title="Telegram contact"
				target="_blank"
				rel="noopener"
			>
				<Icon title="Telegram Icon" path={mdiMessage} size="1.5em" />
				<span>Telegram</span>
				<Icon path={mdiOpenInNew} />
			</a>
		</li>
	</ul>
</section>

<style>
	.landing {
		grid-area: landing;
	}

	h1 :global(.svg-icon) {
		top: 0.15em; /* visual balance */
	}

	hr {
		width: 4em;
		margin: calc(1.5 * var(--line-space)) 0;
	}

	ul.links {
		display: flex;
		flex-direction: column;
		list-style-type: none;
		margin-bottom: var(--line-space);
	}

	ul.links li {
		float: left;
		margin-bottom: var(--line-space);
	}

	ul.links a {
		display: flex;
		align-items: center;
		float: left;
	}

	ul.links a:hover {
		text-decoration: underline;
	}

	ul.links span {
		padding-left: 0.75em;
		padding-right: 0.6em;
	}
</style>
