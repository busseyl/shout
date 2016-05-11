{{#if users.length}}
<div class="count">
	<input class="search" placeholder="{{users users.length}}">
</div>
{{/if}}
<div class="names">
	<div class="inner">
		{{#diff "reset"}}{{/diff}}
		{{#each users}}
			{{#diff mode}}
			{{#unless @first}}
				</div>
			{{/unless}}
			<div class="user-mode {{modes mode}}">
			{{/diff}}
			<div class="wrapper">
				<button class="voice" data-name="{{name}}"><i class="fa fa-lg fa-phone" aria-hidden="true"></i></button>
				<button class="user" style="color: #{{stringcolor name}};">{{mode}}{{name}}</button>
			</div>
		{{/each}}
		</div>
	</div>
</div>