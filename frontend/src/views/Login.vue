<template>
  <div id="login" :class="{ recaptcha: recaptcha }">
    <form @submit="submit">
      <svg
        t="1632630992200"
        class="icon"
        viewBox="0 0 1024 1024"
        version="1.1"
        xmlns="http://www.w3.org/2000/svg"
        p-id="8721"
        width="42"
        height="42"
      >
        <path
          d="M725.333333 768a85.333333 85.333333 0 0 0 85.333334-85.333333V298.666667a85.333333 85.333333 0 0 0-85.333334-85.333334h-195.84a42.666667 42.666667 0 0 1-29.866666-12.373333l-60.586667-60.586667a42.666667 42.666667 0 0 0-29.866667-12.373333H128a85.333333 85.333333 0 0 0-85.333333 85.333333v469.333334a85.333333 85.333333 0 0 0 85.333333 85.333333zM320 256A64 64 0 1 1 256 320 64 64 0 0 1 320 256z m405.333333 405.333333a21.333333 21.333333 0 0 1-21.333333 21.333334h-554.666667a21.333333 21.333333 0 0 1-21.333333-21.333334v-14.506666a19.626667 19.626667 0 0 1 4.693333-12.8L256 477.44a22.186667 22.186667 0 0 1 14.933333-8.106667 21.333333 21.333333 0 0 1 16.64 7.68l61.866667 74.666667a20.906667 20.906667 0 0 0 16.213333 7.68 21.76 21.76 0 0 0 17.066667-8.533333l122.88-158.72a21.76 21.76 0 0 1 34.133333 0l181.333334 241.92a21.76 21.76 0 0 1 4.266666 12.8zM896 384v384a85.333333 85.333333 0 0 1-85.333333 85.333333H213.333333a85.333333 85.333333 0 0 0 85.333334 85.333334h512a170.666667 170.666667 0 0 0 170.666666-170.666667v-298.666667a85.333333 85.333333 0 0 0-85.333333-85.333333z"
          p-id="8722"
          fill="#e6e6e6"
        ></path>
      </svg>
      <h1>{{ name }}</h1>
      <div v-if="error !== ''" class="wrong">{{ error }}</div>

      <input
        class="input input--block"
        type="text"
        v-model="username"
        :placeholder="$t('login.username')"
      />
      <input
        class="input input--block"
        type="password"
        v-model="password"
        :placeholder="$t('login.password')"
      />
      <input
        class="input input--block"
        v-if="createMode"
        type="password"
        v-model="passwordConfirm"
        :placeholder="$t('login.passwordConfirm')"
      />

      <div v-if="recaptcha" id="recaptcha"></div>
      <input
        class="button button--block"
        type="submit"
        :value="createMode ? $t('login.signup') : $t('login.submit')"
      />

      <p @click="toggleMode" v-if="signup">
        {{
          createMode ? $t("login.loginInstead") : $t("login.createAnAccount")
        }}
      </p>
    </form>
  </div>
</template>

<script>
import * as auth from "@/utils/auth";
import {
  name,
  logoURL,
  recaptcha,
  recaptchaKey,
  signup,
} from "@/utils/constants";

export default {
  name: "login",
  computed: {
    signup: () => signup,
    name: () => name,
    logoURL: () => logoURL,
  },
  data: function () {
    return {
      createMode: false,
      error: "",
      username: "",
      password: "",
      recaptcha: recaptcha,
      passwordConfirm: "",
    };
  },
  mounted() {
    if (!recaptcha) return;

    window.grecaptcha.ready(function () {
      window.grecaptcha.render("recaptcha", {
        sitekey: recaptchaKey,
      });
    });
  },
  methods: {
    toggleMode() {
      this.createMode = !this.createMode;
    },
    async submit(event) {
      event.preventDefault();
      event.stopPropagation();

      let redirect = this.$route.query.redirect;
      if (redirect === "" || redirect === undefined || redirect === null) {
        redirect = "/files/";
      }

      let captcha = "";
      if (recaptcha) {
        captcha = window.grecaptcha.getResponse();

        if (captcha === "") {
          this.error = this.$t("login.wrongCredentials");
          return;
        }
      }

      if (this.createMode) {
        if (this.password !== this.passwordConfirm) {
          this.error = this.$t("login.passwordsDontMatch");
          return;
        }
      }

      try {
        if (this.createMode) {
          await auth.signup(this.username, this.password);
        }

        await auth.login(this.username, this.password, captcha);
        this.$router.push({ path: redirect });
      } catch (e) {
        if (e.message == 409) {
          this.error = this.$t("login.usernameTaken");
        } else {
          this.error = this.$t("login.wrongCredentials");
        }
      }
    },
  },
};
</script>
